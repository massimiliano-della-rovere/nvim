-- ============================================================
-- oop_signs.lua -- Neovim 0.12 / 0.13-compatible
-- ============================================================
-- Semantica dei segni nella sign column:
--
--   ↓  OopImplemented
--      Il metodo è definito QUI per la prima volta nella gerarchia
--      (nessuna sopraclasse lo definisce), ma almeno una sottoclasse
--      lo ridefinisce.  Esempio: A.x nella gerarchia A → B → C.
--
--   ↕  OopBoth
--      Il metodo sovrascrive qualcosa nella sopraclasse ED è a sua
--      volta riscritto in almeno una sottoclasse.  Esempio: B.x.
--
--   ↑  OopOverride
--      Il metodo sovrascrive la sopraclasse ma nessuna sottoclasse
--      lo ridefinisce ulteriormente (foglia della gerarchia).
--      Esempio: C.x.
--
-- Regola: "sovrascrive la sopraclasse" (is_override) è determinato:
--
--   Python  → camminata Lua sull'AST Treesitter: is_override = true
--             solo se il metodo porta il decorator @override oppure
--             @typing.override (o qualsiasi qualificazione X.override),
--             in QUALSIASI posizione nello stack di decorator e
--             indipendentemente da quanti altri decorator siano
--             presenti (@staticmethod, @classmethod, @abstractmethod,
--             @property, @functools.wraps, decorator user-made, ecc.).
--             Non richiede alcuna chiamata LSP.
--
--   TypeScript / JavaScript → query TS su class_heritage (extends).
--             Approssimazione sintattica: tutti i metodi in una classe
--             con ereditarietà dichiarata sono considerati override.
--             Possibili falsi positivi per metodi unici della
--             sottoclasse non presenti nel genitore, ma non richiede
--             chiamate LSP aggiuntive.
--
-- Regola: "è ridefinito da una sottoclasse" (has_children) è
-- determinato tramite textDocument/implementation (LSP).
-- ============================================================

local M = {}

local NS = vim.api.nvim_create_namespace("oop_signs")
M._ns = NS

-- ─────────────────────────────────────────────────────────────
-- Segni
-- ─────────────────────────────────────────────────────────────

local SIGN = {
  override    = { text = "\xe2\x86\x91", hl = "DiagnosticHint" }, -- ↑
  implemented = { text = "\xe2\x86\x93", hl = "DiagnosticHint" }, -- ↓
  both        = { text = "\xe2\x86\x95", hl = "DiagnosticHint" }, -- ↕
}

-- Numero massimo di righe di decorator che possono precedere "def".
-- Usato nel filtro is_self_location.
local MAX_DECO_DELTA = 10

-- ─────────────────────────────────────────────────────────────
-- TS_OVERRIDE_QUERIES (solo TypeScript / JavaScript)
-- Per Python si usa is_override_node() (camminata Lua sull'AST).
-- ─────────────────────────────────────────────────────────────

local TS_OVERRIDE_QUERIES = {
  typescript = [[
    (class_declaration (class_heritage) body: (class_body
      [ (method_definition        name: (property_identifier) @method_name)
        (decorated_definition
          (method_definition      name: (property_identifier) @method_name)) ]
    ))
  ]],
  javascript = [[
    (class_declaration (class_heritage) body: (class_body
      [ (method_definition        name: (property_identifier) @method_name)
        (decorated_definition
          (method_definition      name: (property_identifier) @method_name)) ]
    ))
  ]],
}

-- ─────────────────────────────────────────────────────────────
-- ALL_QUERIES: tutti i metodi in qualsiasi classe
-- ─────────────────────────────────────────────────────────────

local ALL_QUERIES = {
  python = [[
    (class_definition body: (_
      [ (function_definition      name: (identifier)         @method_name)
        (decorated_definition
          (function_definition    name: (identifier)         @method_name)) ]
    ))
  ]],
  typescript = [[
    (class_declaration body: (class_body
      [ (method_definition        name: (property_identifier) @method_name)
        (decorated_definition
          (method_definition      name: (property_identifier) @method_name)) ]
    ))
  ]],
  javascript = [[
    (class_declaration body: (class_body
      [ (method_definition        name: (property_identifier) @method_name)
        (decorated_definition
          (method_definition      name: (property_identifier) @method_name)) ]
    ))
  ]],
}

-- ─────────────────────────────────────────────────────────────
-- MNAME_QUERIES: nome del metodo a una certa riga
-- ─────────────────────────────────────────────────────────────

local MNAME_QUERIES = {
  python     = [[ [ (function_definition  name: (identifier)          @n)
                    (decorated_definition
                      (function_definition name: (identifier)          @n)) ] ]],
  typescript = [[ [ (method_definition    name: (property_identifier)  @n)
                    (decorated_definition
                      (method_definition   name: (property_identifier)  @n)) ] ]],
  javascript = [[ [ (method_definition    name: (property_identifier)  @n)
                    (decorated_definition
                      (method_definition   name: (property_identifier)  @n)) ] ]],
}

local _mname_query_cache = {}

-- ─────────────────────────────────────────────────────────────
-- is_override_node  (Python only)
-- ─────────────────────────────────────────────────────────────
-- Restituisce true se il metodo identificato da `name_node`
-- (il nodo (identifier) dentro function_definition) porta il
-- decorator @override oppure qualsiasi forma X.override
-- (@typing.override, ecc.) in qualsiasi posizione nello stack
-- di decoratori.
--
-- PERCHÉ CAMMINATA LUA invece di query con #eq?:
-- Le query TS con predicati (#eq? @cap "valore") abbinano i figli
-- in ordine.  Con più decorator, es:
--   @staticmethod
--   @override
--   def x(): ...
-- il motore deve abbinare prima il decorator con "override" (figlio 1)
-- e poi function_definition (figlio 2).  Nella specifica tree-sitter
-- questo è corretto, ma alcune versioni del grammar compilato in
-- Neovim gestiscono male l'abbinamento non-adiacente, rendendo il
-- risultato dipendente dall'ordine dei decorator.
-- La camminata Lua scorre tutti i figli di decorated_definition
-- indipendentemente dalla posizione: deterministico e grammar-agnostico.

local function is_override_node(name_node, bufnr)
  -- Struttura dell'albero per un metodo decorato:
  --   (identifier)              ← name_node (il nome del metodo)
  --     parent: (function_definition)
  --       parent: (decorated_definition)
  --         child: (decorator) × N   ← uno per ogni @xyz
  --         child: (function_definition)

  local func_node = name_node:parent()          -- function_definition
  if not func_node then return false end

  local deco_def = func_node:parent()           -- decorated_definition oppure block
  if not deco_def or deco_def:type() ~= "decorated_definition" then
    return false   -- metodo non decorato → sicuramente non @override
  end

  -- Scorri tutti i figli di decorated_definition
  for i = 0, deco_def:child_count() - 1 do
    local child = deco_def:child(i)
    if child and child:type() == "decorator" then

      -- Un decorator ha un unico figlio named (il corpo dopo il "@").
      -- Forme supportate:
      --   @override          → (identifier "override")
      --   @typing.override   → (attribute ... attribute: (identifier "override"))
      --   @override(...)     → (call function: (identifier "override") ...)  — raro, ignorato
      --   @X.Y.override      → (attribute ... attribute: (identifier "override"))

      local body = child:named_child(0)
      if body then
        local btype = body:type()

        if btype == "identifier" then
          -- @override  (forma più comune dopo "from typing import override")
          if vim.treesitter.get_node_text(body, bufnr) == "override" then
            return true
          end

        elseif btype == "attribute" then
          -- @typing.override  oppure  @qualcosa.override
          -- In tree-sitter Python, (attribute) ha un campo "attribute"
          -- che è l'(identifier) dopo l'ultimo punto.
          --
          -- API corretta Neovim 0.12+: node:field(name) → tabella di nodi.
          -- child_by_field_name() è l'API C di tree-sitter, NON esposta
          -- nelle binding Lua di Neovim; usarla causa "attempt to call
          -- method 'child_by_field_name' (a nil value)".
          local attrs = body:field("attribute")
          local attr  = attrs and attrs[1]
          if attr and vim.treesitter.get_node_text(attr, bufnr) == "override" then
            return true
          end
        end
        -- btype == "call" (@override() o @typing.override()): ignorato,
        -- non è il pattern standard di typing.override.
      end
    end
  end

  return false
end

-- ─────────────────────────────────────────────────────────────
-- get_method_info_at_row
-- ─────────────────────────────────────────────────────────────
-- Restituisce (method_name, name_col, def_row):
--   method_name → testo dell'identificatore del metodo
--   name_col    → colonna dell'identificatore (per chiamate LSP)
--   def_row     → riga del "def" (può differire da `row` se il
--                 cursore è su un decorator)
-- Cerca in avanti fino a MAX_DECO_DELTA righe per gestire il caso
-- in cui il cursore sia su un decorator sopra il def.

local function get_method_info_at_row(bufnr, row)
  local lang = vim.bo[bufnr].filetype
  local src  = MNAME_QUERIES[lang]
  if not src then return nil, 0, row end

  if not _mname_query_cache[lang] then
    local ok, q = pcall(vim.treesitter.query.parse, lang, src)
    if not ok then return nil, 0, row end
    _mname_query_cache[lang] = q
  end

  local query  = _mname_query_cache[lang]
  local ok_p, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
  if not ok_p or not parser then return nil, 0, row end

  local tree = parser:parse()[1]
  if not tree then return nil, 0, row end

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  for delta = 0, MAX_DECO_DELTA do
    local target = row + delta
    if target >= line_count then break end
    for id, node in query:iter_captures(tree:root(), bufnr, target, target + 1) do
      if query.captures[id] == "n" then
        local nr, nc = node:range()
        if nr == target then
          return vim.treesitter.get_node_text(node, bufnr), nc, target
        end
      end
    end
  end

  return nil, 0, row
end

-- ─────────────────────────────────────────────────────────────
-- Helper: client LSP
-- ─────────────────────────────────────────────────────────────

local function find_impl_client(bufnr)
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if c.server_capabilities.implementationProvider then return c end
  end
  return nil
end

local function find_def_sym_client(bufnr)
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if c.server_capabilities.definitionProvider
    and c.server_capabilities.documentSymbolProvider then
      return c
    end
  end
  return nil
end

-- ─────────────────────────────────────────────────────────────
-- Helper: salta a una location LSP
-- ─────────────────────────────────────────────────────────────
-- vim.lsp.util.jump_to_location() è deprecata dal Neovim 0.11 e
-- rimossa nel 0.13.  Il sostituto ufficiale è show_document(), che
-- ha la stessa semantica ma firma diversa:
--   show_document(location, offset_encoding, { focus, reuse_win })
-- Disponibile da Neovim 0.10; compatibile con 0.12 e 0.13.

local function goto_location(loc, offset_encoding)
  vim.lsp.util.show_document({
    uri   = loc.uri   or loc.targetUri,
    range = loc.range or loc.targetSelectionRange or loc.targetRange,
  }, offset_encoding or "utf-16", { focus = true, reuse_win = true })
end

-- ─────────────────────────────────────────────────────────────
-- Menu multi-destinazione
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
  vim.ui.select(
    vim.tbl_map(function(d) return d.label end, destinations),
    { prompt = "Naviga a:", kind = "oop_navigation" },
    function(_, idx)
      if idx then goto_location(destinations[idx], offset_encoding) end
    end)
end

-- ─────────────────────────────────────────────────────────────
-- first_nonws_col
-- ─────────────────────────────────────────────────────────────
-- Restituisce la colonna (0-based) del primo carattere non-whitespace
-- della riga `row` nel buffer `bufnr`, oppure 0 se la riga è vuota.
--
-- PERCHÉ È NECESSARIA:
-- named_descendant_for_range(row, 0, row, 0) chiede il nodo più
-- piccolo che *contenga* la posizione (row, 0).  Per un metodo
-- indentato di N spazi, tutti i nodi significativi (decorator,
-- function_definition, ecc.) iniziano alla colonna N, non alla 0.
-- La posizione (row, 0) ricade nel whitespace *prima* del nodo,
-- quindi viene restituito l'antenato più lontano che la contenga
-- (tipicamente il block della classe).  Risalire da lì con
-- :parent() porta a class_definition → module, mai a
-- decorated_definition.
-- Usando first_nonws_col si parte da dentro il testo del decorator,
-- e la discesa trova il nodo foglia corretto.

local function first_nonws_col(bufnr, row)
  local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
  local pos  = line:find("[^%s]")   -- 1-based in Lua
  return pos and (pos - 1) or 0     -- converti a 0-based
end

-- ─────────────────────────────────────────────────────────────
-- get_containing_class
-- ─────────────────────────────────────────────────────────────
-- Risale l'AST dalla riga def_row e restituisce il nodo
-- class_definition / class_declaration che contiene il metodo.

local function get_containing_class(bufnr, def_row)
  local lang = vim.bo[bufnr].filetype
  local ok_p, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
  if not ok_p or not parser then return nil end
  local tree = parser:parse()[1]
  if not tree then return nil end

  local col  = first_nonws_col(bufnr, def_row)
  local node = tree:root():named_descendant_for_range(def_row, col, def_row, col)

  while node do
    local t = node:type()
    if t == "class_definition" or t == "class_declaration" then
      return node
    end
    node = node:parent()
  end
  return nil
end

-- ─────────────────────────────────────────────────────────────
-- get_superclass_nodes
-- ─────────────────────────────────────────────────────────────
-- Dato il nodo class_definition, restituisce la lista di
-- { name, row, col } per ogni superclasse dichiarata.
-- Usata per chiamare textDocument/definition sul nome della
-- superclasse e ottenere il file in cui è definita.
--
-- Python  : class B(A, C):       → [A, C]
--           class B(mod.A):      → [mod.A] (nodo attribute)
-- TS / JS : class B extends A {} → [A]

local function get_superclass_nodes(bufnr, class_node, lang)
  local result = {}

  if lang == "python" then
    -- (class_definition superclasses: (argument_list identifier* ...))
    local supers = class_node:field("superclasses")
    if not supers or vim.tbl_isempty(supers) then return result end
    local arg_list = supers[1]
    for i = 0, arg_list:named_child_count() - 1 do
      local child = arg_list:named_child(i)
      if child then
        local r, c = child:range()
        table.insert(result, {
          name = vim.treesitter.get_node_text(child, bufnr),
          row  = r,
          col  = c,
        })
      end
    end

  elseif lang == "typescript" or lang == "javascript" then
    -- (class_declaration (class_heritage (extends_clause value: ...)))
    for i = 0, class_node:child_count() - 1 do
      local ch = class_node:child(i)
      if ch and ch:type() == "class_heritage" then
        for j = 0, ch:named_child_count() - 1 do
          local ext = ch:named_child(j)
          if ext and (ext:type() == "extends_clause"
                   or ext:type() == "implements_clause") then
            local val = ext:named_child(0)
            if val then
              local r, c = val:range()
              table.insert(result, {
                name = vim.treesitter.get_node_text(val, bufnr),
                row  = r,
                col  = c,
              })
            end
          end
        end
      end
    end
  end

  return result
end

-- ─────────────────────────────────────────────────────────────
-- find_method_in_buf
-- ─────────────────────────────────────────────────────────────
-- Cerca `method_name` nelle classi il cui nome è in `class_set`
-- (tabella nome→true) dentro il buffer `tbuf`.
-- Approccio puramente TreeSitter: zero chiamate LSP.
-- Funziona per qualunque combinazione di decorator.
--
-- Restituisce una lista di destination { uri, range, label }.

local function find_method_in_buf(tbuf, method_name, class_set, uri_override)
  local tlang = vim.bo[tbuf].filetype
  -- Per buffer appena caricati il filetype può essere vuoto:
  -- prova a dedurlo dall'estensione del nome file.
  if tlang == "" then
    local fname = vim.api.nvim_buf_get_name(tbuf)
    local ext   = fname:match("%.([^%.]+)$") or ""
    tlang = ({ py = "python", ts = "typescript", js = "javascript" })[ext] or ""
  end

  local src = ALL_QUERIES[tlang]
  if not src then return {} end

  local ok_p, parser = pcall(vim.treesitter.get_parser, tbuf, tlang)
  if not ok_p or not parser then return {} end
  local ok_q, query  = pcall(vim.treesitter.query.parse, tlang, src)
  if not ok_q or not query then return {} end
  local tree = parser:parse()[1]
  if not tree then return {} end

  local target_uri = uri_override or vim.uri_from_bufnr(tbuf)
  local disp_path  = vim.fn.fnamemodify(vim.uri_to_fname(target_uri), ":~:.")
  local results    = {}

  for id, node in query:iter_captures(tree:root(), tbuf, 0, -1) do
    if query.captures[id] == "method_name" then
      local mname = vim.treesitter.get_node_text(node, tbuf)
      if mname == method_name then
        local def_row, def_col = node:range()

        -- Risali l'albero fino al class_definition del metodo.
        -- Struttura Python:
        --   class_definition → body:block → [decorated_definition →]
        --   function_definition → name:identifier
        local func = node:parent()            -- function_definition
        local up   = func and func:parent()   -- decorated_definition o block
        if up and up:type() == "decorated_definition" then
          up = up:parent()                    -- block
        end
        local class_node = up and up:parent() -- class_definition

        if class_node
        and (class_node:type() == "class_definition"
          or class_node:type() == "class_declaration")
        then
          local cnn_list = class_node:field("name")
          local cnn      = cnn_list and cnn_list[1]
          if cnn then
            local class_name = vim.treesitter.get_node_text(cnn, tbuf)
            if class_set[class_name] then
              table.insert(results, {
                uri   = target_uri,
                range = { start   = { line = def_row, character = def_col },
                          ["end"] = { line = def_row, character = def_col } },
                label = string.format("%s.%s  [%s:%d]",
                  class_name, method_name, disp_path, def_row + 1),
              })
            end
          end
        end
      end
    end
  end

  return results
end

-- ─────────────────────────────────────────────────────────────
-- scan_file_classes
-- ─────────────────────────────────────────────────────────────
-- Due passate TS sullo stesso buffer, restituisce:
--   class_supers  : class_name  → { super_name, ... }
--   class_methods : class_name  → { method_name → {row, col} }
--
-- Usata da goto_super per risalire l'INTERA gerarchia (non solo
-- la sopraclasse diretta), così da raccogliere tutti gli antenati
-- che definiscono il metodo e permettere la scelta nel menu.

local function scan_file_classes(bufnr, lang)
  local class_supers  = {}
  local class_methods = {}

  local ok_p, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
  if not ok_p or not parser then return {}, {} end
  local tree = parser:parse()[1]
  if not tree then return {}, {} end

  -- Passata 1: visita DFS dell'intero AST per raccogliere
  -- tutte le classi e le loro sopraclassi dichiarate.
  local function collect_classes(node)
    local t = node:type()
    if t == "class_definition" or t == "class_declaration" then
      local nn = node:field("name")
      if nn and nn[1] then
        local cname  = vim.treesitter.get_node_text(nn[1], bufnr)
        local supers = {}
        if lang == "python" then
          local sf = node:field("superclasses")
          if sf and sf[1] then
            local al = sf[1]
            for j = 0, al:named_child_count() - 1 do
              local sc = al:named_child(j)
              if sc then
                table.insert(supers, vim.treesitter.get_node_text(sc, bufnr))
              end
            end
          end
        elseif lang == "typescript" or lang == "javascript" then
          for j = 0, node:child_count() - 1 do
            local ch = node:child(j)
            if ch and ch:type() == "class_heritage" then
              for k = 0, ch:named_child_count() - 1 do
                local ext = ch:named_child(k)
                if ext and (ext:type() == "extends_clause"
                         or ext:type() == "implements_clause") then
                  local val = ext:named_child(0)
                  if val then
                    table.insert(supers, vim.treesitter.get_node_text(val, bufnr))
                  end
                end
              end
            end
          end
        end
        class_supers[cname] = supers
      end
    end
    for i = 0, node:child_count() - 1 do
      local child = node:child(i)
      if child then collect_classes(child) end
    end
  end
  collect_classes(tree:root())

  -- Passata 2: ALL_QUERIES → mappa classe → metodi con posizione.
  local src = ALL_QUERIES[lang]
  if src then
    local ok_q, query = pcall(vim.treesitter.query.parse, lang, src)
    if ok_q and query then
      for id, node in query:iter_captures(tree:root(), bufnr, 0, -1) do
        if query.captures[id] == "method_name" then
          local mname        = vim.treesitter.get_node_text(node, bufnr)
          local def_row, def_col = node:range()
          local func = node:parent()
          local up   = func and func:parent()
          if up and up:type() == "decorated_definition" then
            up = up:parent()
          end
          local cls = up and up:parent()
          if cls and (cls:type() == "class_definition"
                   or cls:type() == "class_declaration") then
            local nn = cls:field("name")
            if nn and nn[1] then
              local cname = vim.treesitter.get_node_text(nn[1], bufnr)
              if not class_methods[cname] then class_methods[cname] = {} end
              class_methods[cname][mname] = { row = def_row, col = def_col }
            end
          end
        end
      end
    end
  end

  return class_supers, class_methods
end

-- ─────────────────────────────────────────────────────────────
-- Navigazione verso SOPRACLASSI (segno ↑ e ↕)
-- ─────────────────────────────────────────────────────────────
-- Strategia a due livelli:
--
-- LIVELLO 1 – TreeSitter puro (stesso buffer):
--   scan_file_classes() costruisce due mappe complete.
--   BFS ricorsiva verso l'alto: raccoglie TUTTI gli antenati
--   che definiscono il metodo, non solo quelli diretti.
--   Esempio: C.x → trova sia B.x che A.x → mostra il menu.
--   Zero chiamate LSP.
--
-- LIVELLO 2 – LSP cross-file (fallback):
--   Se il livello 1 non trova nulla (sopraclasse in altro file),
--   usa textDocument/definition sull'identificatore della
--   sopraclasse diretta → URI → TreeSitter nel buffer target.

local function goto_super(bufnr, row)
  local method_name, _, def_row = get_method_info_at_row(bufnr, row)
  if not method_name then
    vim.notify("OOP: impossibile determinare il nome del metodo", vim.log.levels.WARN)
    return
  end

  local lang       = vim.bo[bufnr].filetype
  local class_node = get_containing_class(bufnr, def_row)
  if not class_node then vim.lsp.buf.definition(); return end

  local cn_list = class_node:field("name")
  local cn_node = cn_list and cn_list[1]
  if not cn_node then vim.lsp.buf.definition(); return end
  local current_class = vim.treesitter.get_node_text(cn_node, bufnr)

  -- ── LIVELLO 1: BFS nell'intero file via TreeSitter ────────────
  local class_supers, class_methods = scan_file_classes(bufnr, lang)

  local destinations = {}
  local visited      = {}
  local current_uri  = vim.uri_from_bufnr(bufnr)
  local fname        = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":~:.")

  -- Visita ricorsiva verso l'alto: aggiunge alla lista ogni classe
  -- antenata che definisce method_name, poi risale ulteriormente.
  local function walk_up(cname)
    if visited[cname] then return end
    visited[cname] = true
    local methods = class_methods[cname]
    if methods and methods[method_name] then
      local pos = methods[method_name]
      table.insert(destinations, {
        uri   = current_uri,
        range = { start   = { line = pos.row, character = pos.col },
                  ["end"] = { line = pos.row, character = pos.col } },
        label = string.format("%s.%s  [%s:%d]",
          cname, method_name, fname, pos.row + 1),
      })
    end
    for _, sname in ipairs(class_supers[cname] or {}) do
      walk_up(sname)
    end
  end

  for _, sname in ipairs(class_supers[current_class] or {}) do
    walk_up(sname)
  end

  if not vim.tbl_isempty(destinations) then
    pick_and_goto(destinations, "utf-8")
    return
  end

  -- ── LIVELLO 2: cross-file via LSP definition ──────────────────
  local sc_list = get_superclass_nodes(bufnr, class_node, lang)
  if vim.tbl_isempty(sc_list) then vim.lsp.buf.definition(); return end

  local client = find_def_sym_client(bufnr)
  if not client then vim.lsp.buf.definition(); return end

  local cross = {}
  local total = #sc_list
  local done  = 0

  local function finish_one()
    done = done + 1
    if done >= total then
      vim.schedule(function()
        if vim.tbl_isempty(cross) then
          vim.lsp.buf.definition()
        else
          pick_and_goto(cross, client.offset_encoding)
        end
      end)
    end
  end

  for _, sc in ipairs(sc_list) do
    local _sc  = sc
    local _set = { [sc.name] = true }

    client:request("textDocument/definition", {
      textDocument = { uri = vim.uri_from_bufnr(bufnr) },
      position     = { line = _sc.row, character = _sc.col },
    }, function(err, result)
      if err or not result then finish_one(); return end
      local locs = vim.islist(result) and result or { result }
      if vim.tbl_isempty(locs) then finish_one(); return end
      local target_uri = locs[1].uri or locs[1].targetUri
      if not target_uri then finish_one(); return end

      vim.schedule(function()
        local tbuf = vim.uri_to_bufnr(target_uri)
        if not vim.api.nvim_buf_is_loaded(tbuf) then vim.fn.bufload(tbuf) end
        local found = find_method_in_buf(tbuf, method_name, _set, target_uri)
        for _, d in ipairs(found) do table.insert(cross, d) end
        finish_one()
      end)
    end, bufnr)
  end
end

-- ─────────────────────────────────────────────────────────────
-- is_self_location
-- ─────────────────────────────────────────────────────────────
-- Restituisce true se la location LSP (uri, line) si riferisce
-- allo stesso metodo identificato da (current_uri, def_row).
-- Usa un range invece dell'uguaglianza esatta perché alcuni LSP
-- (es. pyright) restituiscono la riga del decorator (@override)
-- invece della riga del def, che può distare 1..N righe.

local function is_self_location(loc_uri, loc_line, current_uri, def_row)
  if loc_uri ~= current_uri then return false end
  return loc_line >= (def_row - MAX_DECO_DELTA) and loc_line <= def_row
end

-- ─────────────────────────────────────────────────────────────
-- Navigazione verso SOTTOCLASSI (segno ↓ e ↕)
-- ─────────────────────────────────────────────────────────────

local function goto_subs(bufnr, row)
  local _, col, def_row = get_method_info_at_row(bufnr, row)
  row = def_row

  local client = find_impl_client(bufnr)
  if not client then
    vim.notify("OOP: LSP non supporta implementation", vim.log.levels.WARN)
    return
  end

  client:request("textDocument/implementation", {
    textDocument = { uri = vim.uri_from_bufnr(bufnr) },
    position     = { line = row, character = col },
  }, function(err, result)
    if err or not result then
      vim.schedule(function()
        vim.notify("OOP: nessuna implementazione trovata", vim.log.levels.INFO)
      end)
      return
    end

    local current_uri  = vim.uri_from_bufnr(bufnr)
    local locs         = vim.islist(result) and result or { result }
    local destinations = {}

    for _, loc in ipairs(locs) do
      local uri   = loc.uri or loc.targetUri
      local range = loc.range or loc.targetSelectionRange or loc.targetRange
      local lnum  = range.start.line
      if not is_self_location(uri, lnum, current_uri, row) then
        table.insert(destinations, {
          uri   = uri,
          range = range,
          label = string.format("%s:%d",
            vim.fn.fnamemodify(vim.uri_to_fname(uri), ":~:."), lnum + 1),
        })
      end
    end

    vim.schedule(function()
      pick_and_goto(destinations, client.offset_encoding)
    end)
  end, bufnr)
end

-- ─────────────────────────────────────────────────────────────
-- def_row_under_cursor
-- ─────────────────────────────────────────────────────────────
-- Se il cursore è su un decorator (di qualsiasi tipo), risale
-- l'albero TS per trovare la riga del "def"/"function" sottostante.
-- Funziona con qualsiasi decorator: @staticmethod, @classmethod,
-- @abstractmethod, @property, @functools.wraps(...), decorator
-- multi-riga con argomenti, ecc.

local function def_row_under_cursor(bufnr, cursor_row)
  local lang = vim.bo[bufnr].filetype
  if lang ~= "python" and lang ~= "typescript" and lang ~= "javascript" then
    return nil
  end

  local ok_p, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
  if not ok_p or not parser then return nil end

  local tree = parser:parse()[1]
  if not tree then return nil end

  -- FIX: usa la colonna del primo carattere non-whitespace invece di 0.
  -- Con col=0 su righe indentate, named_descendant_for_range restituisce
  -- il block/class_definition antenato, rendendo impossibile trovare
  -- decorated_definition risalendo l'albero.
  local col  = first_nonws_col(bufnr, cursor_row)
  local node = tree:root():named_descendant_for_range(
    cursor_row, col, cursor_row, col)

  while node do
    if node:type() == "decorated_definition" then
      for i = 0, node:child_count() - 1 do
        local child = node:child(i)
        if child and (child:type() == "function_definition"
                   or child:type() == "method_definition") then
          return (child:range())   -- start_row 0-based
        end
      end
    end
    node = node:parent()
  end

  return nil
end

-- ─────────────────────────────────────────────────────────────
-- resolve_sign_row
-- ─────────────────────────────────────────────────────────────
-- Trova la riga dell'extmark OOP, cercando anche su righe adiacenti
-- (il cursore potrebbe essere su un qualsiasi decorator, non sul def).
-- Restituisce (sign_row, sign_text) o (nil, nil) se non trovato.

local function resolve_sign_row(bufnr, cursor_row)
  local function marks_at(r)
    return vim.api.nvim_buf_get_extmarks(
      bufnr, NS, { r, 0 }, { r, -1 }, { details = true })
  end

  -- 1. Riga esatta
  local marks = marks_at(cursor_row)
  if not vim.tbl_isempty(marks) then
    return cursor_row, marks[1][4].sign_text or ""
  end

  -- 2. Cursore su decorator → trova il def tramite TS (risalita albero)
  local def_row = def_row_under_cursor(bufnr, cursor_row)
  if def_row then
    marks = marks_at(def_row)
    if not vim.tbl_isempty(marks) then
      return def_row, marks[1][4].sign_text or ""
    end
  end

  -- 3. Fallback: ricerca in avanti riga per riga (es. cursore sulla
  --    riga "@" di un decorator multi-riga con argomenti)
  local _, _, found_row = get_method_info_at_row(bufnr, cursor_row)
  if found_row ~= cursor_row then
    marks = marks_at(found_row)
    if not vim.tbl_isempty(marks) then
      return found_row, marks[1][4].sign_text or ""
    end
  end

  return nil, nil
end

-- ─────────────────────────────────────────────────────────────
-- show_navigation_menu
-- ─────────────────────────────────────────────────────────────

local function show_navigation_menu(bufnr, row, sign_text)
  local is_up   = sign_text:find("\xe2\x86\x91") ~= nil  -- ↑ E2 86 91
  local is_down = sign_text:find("\xe2\x86\x93") ~= nil  -- ↓ E2 86 93
  local is_both = sign_text:find("\xe2\x86\x95") ~= nil  -- ↕ E2 86 95

  if is_both then
    vim.ui.select(
      { "\xe2\x86\x91  Vai alla definizione nella sopraclasse",
        "\xe2\x86\x93  Vai alle implementazioni nelle sottoclassi" },
      { prompt = "OOP – Direzione:", kind = "oop_navigation" },
      function(choice)
        if not choice then return end
        if choice:sub(1, 3) == "\xe2\x86\x91" then
          goto_super(bufnr, row)
        else
          goto_subs(bufnr, row)
        end
      end)
  elseif is_up   then goto_super(bufnr, row)
  elseif is_down then goto_subs(bufnr, row)
  end
end

-- ─────────────────────────────────────────────────────────────
-- M.goto_related  (keymap: gO)
-- ─────────────────────────────────────────────────────────────

function M.goto_related(bufnr, row)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  row   = row   or (vim.api.nvim_win_get_cursor(0)[1] - 1)

  local sign_row, sign_text = resolve_sign_row(bufnr, row)
  if not sign_row then
    vim.lsp.buf.definition()
    return
  end
  show_navigation_menu(bufnr, sign_row, sign_text)
end

-- ─────────────────────────────────────────────────────────────
-- get_ts_override_rows  (TypeScript / JavaScript only)
-- Mappa riga→true per i metodi con is_override=true via query TS.
-- Per Python si usa is_override_node() direttamente in M.refresh.
-- ─────────────────────────────────────────────────────────────

local function get_ts_override_rows(bufnr, lang)
  local result = {}
  local src    = TS_OVERRIDE_QUERIES[lang]
  if not src then return result end

  local ok_p, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
  if not ok_p or not parser then return result end

  local ok_q, query = pcall(vim.treesitter.query.parse, lang, src)
  if not ok_q or not query then return result end

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

-- ─────────────────────────────────────────────────────────────
-- has_implementations
-- ─────────────────────────────────────────────────────────────
-- Chiama cb(true) se esiste almeno una implementazione del metodo
-- in una sottoclasse DIVERSA dal metodo corrente, cb(false) altrimenti.
--
-- Il filtro is_self_location usa un range per gestire il caso in cui
-- l'LSP restituisca la riga del decorator invece della riga del def.

local function has_implementations(client, bufnr, def_row, col, cb)
  local params = {
    textDocument = { uri = vim.uri_from_bufnr(bufnr) },
    position     = { line = def_row, character = col },
  }

  local ok = client:request("textDocument/implementation", params,
    function(err, result)
      if err or not result or vim.tbl_isempty(result) then
        cb(false); return
      end

      local current_uri = vim.uri_from_bufnr(bufnr)
      local locs        = vim.islist(result) and result or { result }

      for _, loc in ipairs(locs) do
        local loc_uri  = loc.uri or loc.targetUri
        local loc_line = (loc.range or loc.targetSelectionRange
                          or loc.targetRange).start.line
        if not is_self_location(loc_uri, loc_line, current_uri, def_row) then
          cb(true); return
        end
      end

      cb(false)
    end, bufnr)

  if not ok then cb(false) end
end

-- ─────────────────────────────────────────────────────────────
-- place_sign
-- ─────────────────────────────────────────────────────────────
--   is_override  has_children  segno
--   false        true          ↓  primo nella gerarchia, ha figli
--   true         true          ↕  nel mezzo
--   true         false         ↑  foglia
--   false        false         (nessun segno)

local function place_sign(bufnr, row, is_override, has_children)
  local s
  if     is_override and has_children then s = SIGN.both
  elseif is_override                  then s = SIGN.override
  elseif has_children                 then s = SIGN.implemented
  else return
  end

  pcall(vim.api.nvim_buf_set_extmark, bufnr, NS, row, 0, {
    sign_text     = s.text,
    sign_hl_group = s.hl,
    priority      = 90,
    invalidate    = true,
  })
end

-- ─────────────────────────────────────────────────────────────
-- M.refresh
-- ─────────────────────────────────────────────────────────────

function M.refresh(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local client
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if c.server_capabilities.implementationProvider then client = c; break end
  end
  if not client then return end

  local lang = vim.bo[bufnr].filetype

  local all_src = ALL_QUERIES[lang]
  if not all_src then return end

  local ok_p, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
  if not ok_p or not parser then return end

  local ok_q, all_query = pcall(vim.treesitter.query.parse, lang, all_src)
  if not ok_q or not all_query then return end

  local tree = parser:parse()[1]
  if not tree then return end

  -- Per TypeScript/JavaScript: tabella riga→true costruita via query TS.
  -- Per Python: non serve, is_override viene calcolato per nodo.
  local ts_override_rows = (lang ~= "python") and
    get_ts_override_rows(bufnr, lang) or nil

  vim.api.nvim_buf_clear_namespace(bufnr, NS, 0, -1)

  for id, node in all_query:iter_captures(tree:root(), bufnr, 0, -1) do
    if all_query.captures[id] == "method_name" then
      local name = vim.treesitter.get_node_text(node, bufnr)

      if name ~= "__init__" and name ~= "constructor" then
        local def_row, col = node:range()

        -- is_override: per Python camminata AST, per TS/JS tabella query.
        local is_override
        if lang == "python" then
          is_override = is_override_node(node, bufnr)
        else
          is_override = (ts_override_rows and ts_override_rows[def_row]) or false
        end

        -- Cattura in locali: le variabili del ciclo `for` vengono
        -- riusate a ogni iterazione; senza questa copia le closure
        -- async vedrebbero l'ultimo valore dell'iteratore.
        local _def_row, _col, _iso = def_row, col, is_override

        has_implementations(client, bufnr, _def_row, _col,
          function(has_children)
            vim.schedule(function()
              place_sign(bufnr, _def_row, _iso, has_children)
            end)
          end)
      end
    end
  end
end

-- ─────────────────────────────────────────────────────────────
-- M.setup
-- ─────────────────────────────────────────────────────────────

function M.setup()

  -- ── Click handler per la sign column ──────────────────────────
  -- Chiamato da statuscol tramite "%@v:lua.OopSignClick@%s%T".
  -- Firma: (minwid, clicks, button, mods)
  --
  -- FIX: vim.fn.getmousepos() è valido SOLO durante il callback
  -- sincrono.  Leggiamo subito, prima di vim.schedule().

  _G.OopSignClick = function(_, _, button, _)
    if button ~= "l" then return end

    local mousepos = vim.fn.getmousepos()
    local winid    = mousepos.winid
    local lnum     = mousepos.line   -- 1-based

    if winid == 0 or lnum == 0 then return end

    local bufnr = vim.api.nvim_win_get_buf(winid)
    local row   = lnum - 1   -- 0-based

    local sign_row, sign_text = resolve_sign_row(bufnr, row)
    if not sign_row then return end

    vim.schedule(function()
      vim.api.nvim_set_current_win(winid)
      vim.api.nvim_win_set_cursor(winid, { lnum, 0 })
      show_navigation_menu(bufnr, sign_row, sign_text)
    end)
  end

  -- ── LspAttach: keymap gO + refresh automatico ─────────────────

  vim.api.nvim_create_autocmd("LspAttach", {
    group    = vim.api.nvim_create_augroup("OopSigns_Attach", { clear = true }),
    callback = function(args)
      local bufnr  = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client then return end

      vim.keymap.set("n", "gO",
        function() M.goto_related(bufnr) end,
        { buffer = bufnr, desc = "OOP: navigate to related class member" })

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
