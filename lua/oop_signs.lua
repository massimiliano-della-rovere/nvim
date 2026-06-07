-- ============================================================
-- oop_signs.lua  --  Neovim 0.12 / 0.13-compatible
-- ============================================================
-- Mostra nella sign column per ogni metodo di classe:
--   ↑  OopOverride    sovrascrive almeno un metodo di una sopraclasse
--   ↓  OopImplemented e' sovrascritto da almeno una sottoclasse
--   ↕  OopBoth        entrambe le condizioni
--
-- I segni sono CLICCABILI (mouse) e navigabili via `gO`:
--   ↑  → vai alla/e definizione/i nella sopraclasse
--   ↓  → vai alla/e implementazione/i nelle sottoclassi
--   ↕  → menu di scelta della direzione
-- In tutti i casi, se ci sono più destinazioni si apre
-- vim.ui.select (telescope-ui-select se disponibile).
-- ============================================================

local M  = {}
local NS = vim.api.nvim_create_namespace("oop_signs")
M._ns    = NS   -- esposto per il click handler globale

-- ─────────────────────────────────────────────────────────────
-- Costanti dei segni (testo UTF-8 come bytes)
-- ─────────────────────────────────────────────────────────────
local SIGN = {
  override    = { text = "\xe2\x86\x91", hl = "DiagnosticHint" },  -- ↑
  implemented = { text = "\xe2\x86\x93", hl = "DiagnosticHint" },  -- ↓
  both        = { text = "\xe2\x86\x95", hl = "DiagnosticHint" },  -- ↕
}

-- ─────────────────────────────────────────────────────────────
-- Queries Treesitter (invariate dalla versione precedente)
-- ─────────────────────────────────────────────────────────────
local QUERIES = {
  python = [[
    (class_definition superclasses: (_) body: (_
      [ (function_definition name: (identifier) @method_name)
        (decorated_definition (function_definition name: (identifier) @method_name)) ]
    ))
  ]],
  typescript = [[
    (class_declaration (class_heritage) body: (class_body
      [ (method_definition name: (property_identifier) @method_name)
        (decorated_definition (method_definition name: (property_identifier) @method_name)) ]
    ))
  ]],
  javascript = [[
    (class_declaration (class_heritage) body: (class_body
      [ (method_definition name: (property_identifier) @method_name)
        (decorated_definition (method_definition name: (property_identifier) @method_name)) ]
    ))
  ]],
}

local ALL_QUERIES = {
  python = [[
    (class_definition body: (_
      [ (function_definition name: (identifier) @method_name)
        (decorated_definition (function_definition name: (identifier) @method_name)) ]
    ))
  ]],
  typescript = [[
    (class_declaration body: (class_body
      [ (method_definition name: (property_identifier) @method_name)
        (decorated_definition (method_definition name: (property_identifier) @method_name)) ]
    ))
  ]],
  javascript = [[
    (class_declaration body: (class_body
      [ (method_definition name: (property_identifier) @method_name)
        (decorated_definition (method_definition name: (property_identifier) @method_name)) ]
    ))
  ]],
}

-- ─────────────────────────────────────────────────────────────
-- Helper: nome e colonna del metodo a una certa riga (0-based)
-- Usa Treesitter per trovare il nodo function/method_definition.
-- ─────────────────────────────────────────────────────────────
-- ── Query per trovare il nome del metodo a una certa riga ──────────────
-- PERCHE' NON USO named_descendant_for_range(row, 0, row, 999):
--   Per un metodo decorato (@typing.override, @typing.final ecc.),
--   il nodo function_definition inizia alla colonna della keyword "def"
--   (es. col 4), non alla colonna 0. Una ricerca da col 0 restituisce
--   decorated_definition che CONTIENE function_definition come FIGLIO,
--   non come genitore. Risalire l'albero con node:parent() non porta
--   mai a function_definition.
-- SOLUZIONE: query:iter_captures limitata alla riga target, che trova
--   esattamente l'identifier del nome del metodo indipendentemente da
--   quanti e quali decoratori lo avvolgano.
local MNAME_QUERIES = {
  python     = [[ [ (function_definition  name: (identifier)          @n)
                    (decorated_definition (function_definition  name: (identifier)          @n)) ] ]],
  typescript = [[ [ (method_definition    name: (property_identifier) @n)
                    (decorated_definition (method_definition    name: (property_identifier) @n)) ] ]],
  javascript = [[ [ (method_definition    name: (property_identifier) @n)
                    (decorated_definition (method_definition    name: (property_identifier) @n)) ] ]],
}
local _mname_query_cache = {}

local function get_method_info_at_row(bufnr, row)
  local lang = vim.bo[bufnr].filetype
  local src  = MNAME_QUERIES[lang]
  if not src then return nil, 0 end

  if not _mname_query_cache[lang] then
    local ok, q = pcall(vim.treesitter.query.parse, lang, src)
    if not ok then return nil, 0 end
    _mname_query_cache[lang] = q
  end
  local query = _mname_query_cache[lang]

  local ok_p, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
  if not ok_p or not parser then return nil, 0 end
  local tree = parser:parse()[1]
  if not tree then return nil, 0 end

  -- iter_captures con range (row, row+1) scansiona solo quella riga:
  -- efficiente e immune alla struttura dei nodi contenitori.
  for id, node in query:iter_captures(tree:root(), bufnr, row, row + 1) do
    if query.captures[id] == "n" then
      local nr, nc = node:range()
      if nr == row then
        return vim.treesitter.get_node_text(node, bufnr), nc
      end
    end
  end
  return nil, 0
end

-- ─────────────────────────────────────────────────────────────
-- Helper: client LSP con typeHierarchyProvider
-- ─────────────────────────────────────────────────────────────
local function find_hierarchy_client(bufnr)
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if c.server_capabilities.typeHierarchyProvider then return c end
  end
  return nil
end

local function find_impl_client(bufnr)
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if c.server_capabilities.implementationProvider then return c end
  end
  return nil
end

-- ─────────────────────────────────────────────────────────────
-- Navigazione: salta a una destinazione LSP
-- Usa vim.lsp.util.jump_to_location per gestire correttamente
-- l'apertura dei file e la jump list.
-- ─────────────────────────────────────────────────────────────
local function goto_location(loc, offset_encoding)
  -- loc = { uri, range } oppure LocationLink
  local location = {
    uri   = loc.uri   or loc.targetUri,
    range = loc.range or loc.targetSelectionRange or loc.targetRange,
  }
  vim.lsp.util.jump_to_location(location, offset_encoding or "utf-16", true)
end

-- ─────────────────────────────────────────────────────────────
-- Menu di selezione multi-destinazione
-- Usa vim.ui.select (telescope-ui-select se caricato).
-- ─────────────────────────────────────────────────────────────
local function pick_and_goto(destinations, offset_encoding)
  if vim.tbl_isempty(destinations) then
    vim.notify("OOP: nessuna destinazione trovata", vim.log.levels.INFO)
    return
  end
  if #destinations == 1 then
    goto_location(destinations[1], offset_encoding)
    return
  end

  local labels = vim.tbl_map(function(d) return d.label end, destinations)
  vim.ui.select(labels, {
    prompt  = "Naviga a:",
    kind    = "oop_navigation",
  }, function(_, idx)
    if idx then goto_location(destinations[idx], offset_encoding) end
  end)
end

-- ─────────────────────────────────────────────────────────────
-- Navigazione verso SOPRACLASSI  (segno ↑)
-- Catena: prepareTypeHierarchy → supertypes → documentSymbol
-- ─────────────────────────────────────────────────────────────
local function goto_super(bufnr, row)
  local method_name, col = get_method_info_at_row(bufnr, row)
  if not method_name then
    vim.notify("OOP: impossibile determinare il nome del metodo", vim.log.levels.WARN)
    return
  end

  local client = find_hierarchy_client(bufnr)
  if not client then
    -- Fallback: LSP definition standard
    vim.lsp.buf.definition()
    return
  end

  local p1 = {
    textDocument = { uri = vim.uri_from_bufnr(bufnr) },
    position     = { line = row, character = col },
  }

  client:request("textDocument/prepareTypeHierarchy", p1, function(e1, items)
    if e1 or not items or vim.tbl_isempty(items) then
      vim.schedule(function() vim.lsp.buf.definition() end)
      return
    end

    client:request("typeHierarchy/supertypes", { item = items[1] },
      function(e2, supertypes)
        if e2 or not supertypes or vim.tbl_isempty(supertypes) then
          vim.schedule(function() vim.lsp.buf.definition() end)
          return
        end

        local skip = { object = true, Any = true, BaseModel = true }
        local relevant = vim.tbl_filter(
          function(st) return not skip[st.name] end, supertypes)
        if vim.tbl_isempty(relevant) then
          vim.schedule(function() vim.lsp.buf.definition() end)
          return
        end

        local destinations = {}
        local pending       = #relevant

        for _, st in ipairs(relevant) do
          local parent_name = st.name
          client:request("textDocument/documentSymbol",
            { textDocument = { uri = st.uri } },
            function(e3, syms)
              pending = pending - 1
              if not e3 and syms then
                for _, sym in ipairs(syms) do
                  if sym.name == parent_name and sym.children then
                    for _, child in ipairs(sym.children) do
                      if child.name == method_name then
                        table.insert(destinations, {
                          uri   = st.uri,
                          range = child.selectionRange or child.range,
                          label = string.format("%s.%s  [%s]",
                            parent_name, method_name,
                            vim.fn.fnamemodify(vim.uri_to_fname(st.uri), ":~:.")),
                        })
                        break
                      end
                    end
                    break
                  end
                end
              end
              if pending == 0 then
                vim.schedule(function()
                  pick_and_goto(destinations, client.offset_encoding)
                end)
              end
            end, bufnr)
        end
      end, bufnr)
  end, bufnr)
end

-- ─────────────────────────────────────────────────────────────
-- Navigazione verso SOTTOCLASSI  (segno ↓)
-- Usa textDocument/implementation, filtra la posizione corrente.
-- ─────────────────────────────────────────────────────────────
local function goto_subs(bufnr, row)
  local _, col = get_method_info_at_row(bufnr, row)
  local client = find_impl_client(bufnr)
  if not client then
    vim.notify("OOP: LSP non supporta implementation", vim.log.levels.WARN)
    return
  end

  local params = {
    textDocument = { uri = vim.uri_from_bufnr(bufnr) },
    position     = { line = row, character = col },
  }

  client:request("textDocument/implementation", params, function(err, result)
    if err or not result then
      vim.schedule(function()
        vim.notify("OOP: nessuna implementazione trovata", vim.log.levels.INFO)
      end)
      return
    end

    local current_uri = vim.uri_from_bufnr(bufnr)
    local locs = vim.islist(result) and result or { result }
    local destinations = {}

    for _, loc in ipairs(locs) do
      local uri   = loc.uri or loc.targetUri
      local range = loc.range or loc.targetSelectionRange or loc.targetRange
      local lnum  = range.start.line

      -- Esclude la posizione corrente
      if uri ~= current_uri or lnum ~= row then
        local fname = vim.fn.fnamemodify(vim.uri_to_fname(uri), ":~:.")
        -- Cerca di estrarre il nome della classe dal path o dal simbolo
        table.insert(destinations, {
          uri   = uri,
          range = range,
          label = string.format("%s:%d", fname, lnum + 1),
        })
      end
    end

    vim.schedule(function()
      pick_and_goto(destinations, client.offset_encoding)
    end)
  end, bufnr)
end

-- ─────────────────────────────────────────────────────────────
-- API pubblica: goto_related
-- Controlla il segno sulla riga corrente (o su `row`) e naviga.
-- ─────────────────────────────────────────────────────────────
-- Cerca la riga del function_definition se il cursore e' su un decoratore.
-- I decoratori (@typing.override, @typing.final, @classmethod ecc.) sono
-- righe SOPRA il def e non hanno extmark: l'extmark e' sul "def".
local function def_row_under_cursor(bufnr, cursor_row)
  local lang = vim.bo[bufnr].filetype
  if lang ~= "python" and lang ~= "typescript" and lang ~= "javascript" then
    return nil
  end
  local ok_p, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
  if not ok_p or not parser then return nil end
  local tree = parser:parse()[1]
  if not tree then return nil end

  -- Trova il nodo piu' specifico alla riga del cursore
  local node = tree:root():named_descendant_for_range(
    cursor_row, 0, cursor_row, 0)
  while node do
    if node:type() == "decorated_definition" then
      -- Cerca il function_definition / method_definition figlio
      for i = 0, node:child_count() - 1 do
        local child = node:child(i)
        if child and (child:type() == "function_definition"
                   or child:type() == "method_definition") then
          return (child:range())  -- restituisce start_row (0-based)
        end
      end
    end
    node = node:parent()
  end
  return nil
end

function M.goto_related(bufnr, row)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  row   = row   or (vim.api.nvim_win_get_cursor(0)[1] - 1)

  -- Legge il segno extmark sulla riga
  local marks = vim.api.nvim_buf_get_extmarks(
    bufnr, NS, { row, 0 }, { row, -1 }, { details = true })

  -- Se nessun segno alla riga corrente, controlla se il cursore e'
  -- su un decoratore (@typing.override ecc.): l'extmark e' sul "def"
  -- che si trova qualche riga piu' in basso.
  if vim.tbl_isempty(marks) then
    local def_row = def_row_under_cursor(bufnr, row)
    if def_row then
      marks = vim.api.nvim_buf_get_extmarks(
        bufnr, NS, { def_row, 0 }, { def_row, -1 }, { details = true })
      if not vim.tbl_isempty(marks) then
        row = def_row   -- usa la riga del def per la navigazione
      end
    end
  end

  if vim.tbl_isempty(marks) then
    vim.lsp.buf.definition()
    return
  end

  local sign_text = marks[1][4].sign_text or ""
  local has_up   = sign_text:find("\xe2\x86\x91") ~= nil  -- ↑
  local has_down = sign_text:find("\xe2\x86\x93") ~= nil  -- ↓
  local has_both = sign_text:find("\xe2\x86\x95") ~= nil  -- ↕

  if has_both then
    vim.ui.select(
      { "\xe2\x86\x91  Vai alla definizione nella sopraclasse",
        "\xe2\x86\x93  Vai alle implementazioni nelle sottoclassi" },
      { prompt = "OOP – Direzione:" },
      function(choice)
        if not choice then return end
        if choice:sub(1, 3) == "\xe2\x86\x91" then
          goto_super(bufnr, row)
        else
          goto_subs(bufnr, row)
        end
      end)
  elseif has_up then
    goto_super(bufnr, row)
  elseif has_down then
    goto_subs(bufnr, row)
  end
end

-- ─────────────────────────────────────────────────────────────
-- Analisi statica e dinamica (invariate)
-- ─────────────────────────────────────────────────────────────
local function get_override_rows(bufnr, lang)
  local result  = {}
  local src     = QUERIES[lang]
  if not src then return result end
  local ok_p, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
  if not ok_p or not parser then return result end
  local ok_q, query  = pcall(vim.treesitter.query.parse, lang, src)
  if not ok_q or not query  then return result end
  local tree = parser:parse()[1]
  if not tree then return result end
  for id, node in query:iter_captures(tree:root(), bufnr, 0, -1) do
    if query.captures[id] == "method_name" then
      local row = node:range()
      result[row] = true
    end
  end
  return result
end

local function has_implementations(client, bufnr, row, col, cb)
  local params = {
    textDocument = { uri = vim.uri_from_bufnr(bufnr) },
    position     = { line = row, character = col },
  }
  local ok = client:request("textDocument/implementation", params,
    function(err, result)
      if err or not result or vim.tbl_isempty(result) then cb(false); return end
      local current_uri = vim.uri_from_bufnr(bufnr)
      local locs = vim.islist(result) and result or { result }
      for _, loc in ipairs(locs) do
        local loc_uri  = loc.uri or loc.targetUri
        local loc_line = (loc.range or loc.targetSelectionRange or loc.targetRange).start.line
        if loc_uri ~= current_uri or loc_line ~= row then cb(true); return end
      end
      cb(false)
    end, bufnr)
  if not ok then cb(false) end
end

local function place_sign(bufnr, row, is_override, has_children)
  local s
  if     is_override and has_children then s = SIGN.both
  elseif is_override                  then s = SIGN.override
  elseif has_children                 then s = SIGN.implemented
  else   return
  end
  pcall(vim.api.nvim_buf_set_extmark, bufnr, NS, row, 0, {
    sign_text     = s.text,
    sign_hl_group = s.hl,
    priority      = 90,
    invalidate    = true,
  })
end

function M.refresh(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local client
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if c.server_capabilities.implementationProvider then client = c; break end
  end
  if not client then return end

  local lang          = vim.bo[bufnr].filetype
  local override_rows = get_override_rows(bufnr, lang)
  local all_src       = ALL_QUERIES[lang]
  if not all_src then return end

  local ok_p, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
  if not ok_p or not parser then return end
  local ok_q, all_query = pcall(vim.treesitter.query.parse, lang, all_src)
  if not ok_q or not all_query then return end
  local tree = parser:parse()[1]
  if not tree then return end

  vim.api.nvim_buf_clear_namespace(bufnr, NS, 0, -1)

  for id, node in all_query:iter_captures(tree:root(), bufnr, 0, -1) do
    if all_query.captures[id] == "method_name" then
      local name = vim.treesitter.get_node_text(node, bufnr)
      if name ~= "__init__" and name ~= "constructor" then
        local row, col    = node:range()
        local is_override = override_rows[row] or false
        local _row, _col, _iso = row, col, is_override
        has_implementations(client, bufnr, _row, _col, function(has_children)
          vim.schedule(function() place_sign(bufnr, _row, _iso, has_children) end)
        end)
      end
    end
  end
end

-- ─────────────────────────────────────────────────────────────
-- Setup: autocmd + keymap globale `gO` + click handler
-- ─────────────────────────────────────────────────────────────
function M.setup()
  -- ── Click handler per il segno nella sign column ─────────
  -- Definito come funzione globale perche' statuscol usa
  -- "v:lua.OopSignClick" (namespace globale Lua).
  -- Se la riga cliccata ha un segno OOP, naviga; altrimenti
  -- cade attraverso al handler standard di statuscol (ScSa).
  _G.OopSignClick = function(_, _, button, _)
    if button ~= "l" then return end   -- solo click sinistro
    local lnum  = vim.v.mouse_lnum
    local bufnr = vim.api.nvim_win_get_buf(vim.fn.getmousepos().winid)
    local row   = lnum - 1  -- 0-based

    local marks = vim.api.nvim_buf_get_extmarks(
      bufnr, NS, { row, 0 }, { row, -1 }, { details = true })
    if not vim.tbl_isempty(marks) then
      -- Reindirizza a goto_related su quel buffer/riga specifici
      vim.schedule(function() M.goto_related(bufnr, row) end)
    end
    -- Se non c'e' segno OOP, non fa nulla (comportamento standard)
  end

  -- ── LspAttach: keymap `gO` buffer-local ──────────────────
  vim.api.nvim_create_autocmd("LspAttach", {
    group    = vim.api.nvim_create_augroup("OopSigns_Attach", { clear = true }),
    callback = function(args)
      local bufnr  = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client then return end

      -- gO: naviga al/ai metodo/i correlato/i nella gerarchia
      -- Funziona anche senza segno OOP sulla riga: in quel caso
      -- cade attraverso a vim.lsp.buf.definition().
      vim.keymap.set("n", "gO",
        function() M.goto_related(bufnr) end,
        { buffer = bufnr, desc = "OOP: navigate to related class" })

      -- Refresh segni solo se il client supporta implementation
      if not client.server_capabilities.implementationProvider then return end

      local group = vim.api.nvim_create_augroup(
        "OopSigns_" .. bufnr, { clear = true })

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
        group    = group,
        buffer   = bufnr,
        callback = function()
          vim.defer_fn(function() M.refresh(bufnr) end, 300)
        end,
      })
      vim.defer_fn(function() M.refresh(bufnr) end, 800)
    end,
  })
end

return M
