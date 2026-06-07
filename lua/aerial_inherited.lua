-- ============================================================
-- aerial_inherited.lua  --  Neovim 0.12 / 0.13-compatible
-- ============================================================
-- Mostra nella finestra di aerial i metodi ereditati da classi
-- parent come virtual lines con stile diverso (italic + attenuato).
--
-- NOTA: aerial per design mostra solo simboli del file corrente.
--   Questo modulo aggiunge i metodi parent come decorazioni
--   (non sono navigabili via CR, ma sono visibili nell'outline).
--
-- DECORATORI (@typing.override, @typing.final, …):
--   Con il backend LSP (default) i metodi decorati appaiono
--   normalmente in aerial — basedpyright li include in
--   documentSymbol indipendentemente dai decoratori.
--   Se aerial usa il backend Treesitter e mancano metodi
--   decorati, aggiungere il backend "lsp" prima di "treesitter"
--   nella configurazione di aerial (già fatto in programming.lua).
--
-- ARCHITETTURA:
--   • User AerialTreeUpdateComplete  →  trigger principale
--     (aerial lo spara dopo ogni aggiornamento dell'albero)
--   • FileType aerial                →  trigger di fallback
--   • LSP typeHierarchy              →  trova i metodi parent
--   • nvim_buf_set_extmark virt_lines →  rendering nel buffer aerial
-- ============================================================

local M  = {}
local NS = vim.api.nvim_create_namespace("aerial_inherited")

-- Mappa: source_bufnr → aerial_bufnr (popolata on_attach + FileType)
local src_to_aerial = {}

-- Cache LSP: source_bufnr → class_key → { parent → method[] }
local lsp_cache = {}

-- ─── Highlights ─────────────────────────────────────────────

local function define_hl()
  vim.api.nvim_set_hl(0, "AerialInheritedMethod",
    { fg = "#7a8a9a", italic = true, default = true })
  vim.api.nvim_set_hl(0, "AerialInheritedMethodSource",
    { fg = "#4a5a6a", italic = true, default = true })
end

-- ─── Trova aerial buffer da source_bufnr ──────────────────
-- Tenta tre approcci in ordine di affidabilità:
-- 1. Mappa interna (popolata da on_attach + FileType)
-- 2. Variabile buffer di aerial (se la versione la espone)
-- 3. Scansione dei buffer aperti con ft=aerial

local function find_aerial_bufnr(source_bufnr)
  -- Approccio 1: mappa interna
  local cached = src_to_aerial[source_bufnr]
  if cached and vim.api.nvim_buf_is_valid(cached) then
    return cached
  end

  -- Approccio 2 + 3: scansiona i buffer aerial aperti
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf)
      and vim.bo[buf].filetype == "aerial" then

      -- 2a: aerial potrebbe salvare il source in una variabile
      for _, varname in ipairs({
        "aerial_source_buf", "aerial_source_bufnr",
      }) do
        local ok, val = pcall(vim.api.nvim_buf_get_var, buf, varname)
        if ok and val == source_bufnr then
          src_to_aerial[source_bufnr] = buf
          return buf
        end
      end

      -- 2b: confronta il titolo della finestra aerial con il nome del file
      local wins = vim.fn.win_findbuf(buf)
      for _, win in ipairs(wins) do
        local prev = vim.fn.win_getid(vim.fn.winnr("#"))
        if prev and prev ~= 0 then
          local prev_buf = vim.api.nvim_win_get_buf(prev)
          if prev_buf == source_bufnr then
            src_to_aerial[source_bufnr] = buf
            return buf
          end
        end
      end
    end
  end
  return nil
end

-- ─── LSP: catena typeHierarchy → documentSymbol ────────────

local function find_hierarchy_client(bufnr)
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if c.server_capabilities.typeHierarchyProvider then return c end
  end
  return nil
end

local function fetch_parent_methods(client, bufnr, lnum, col, cb)
  local p = {
    textDocument = { uri = vim.uri_from_bufnr(bufnr) },
    position     = { line = lnum - 1, character = col },
  }
  local ok1 = client:request("textDocument/prepareTypeHierarchy", p,
    function(e1, items)
      if e1 or not items or vim.tbl_isempty(items) then cb({}); return end

      local ok2 = client:request("typeHierarchy/supertypes",
        { item = items[1] },
        function(e2, supertypes)
          if e2 or not supertypes or vim.tbl_isempty(supertypes) then
            cb({})
            return
          end

          local skip    = { object = true, Any = true }
          local results = {}
          local pending = 0

          for _, st in ipairs(supertypes) do
            if not skip[st.name] then pending = pending + 1 end
          end

          if pending == 0 then cb({}); return end

          for _, st in ipairs(supertypes) do
            if not skip[st.name] then
              local pname = st.name
              local ok3   = client:request(
                "textDocument/documentSymbol",
                { textDocument = { uri = st.uri } },
                function(e3, syms)
                  pending = pending - 1
                  if not e3 and syms then
                    for _, sym in ipairs(syms) do
                      if sym.name == pname
                        and sym.kind == 5   -- Class
                        and sym.children then
                        results[pname] = {}
                        for _, ch in ipairs(sym.children) do
                          if (ch.kind == 6 or ch.kind == 12)
                            and ch.name ~= "__init__"
                            and ch.name ~= "constructor" then
                            table.insert(results[pname], ch.name)
                          end
                        end
                        break
                      end
                    end
                  end
                  if pending == 0 then cb(results) end
                end, bufnr)

              if not ok3 then
                pending = pending - 1
                if pending == 0 then cb(results) end
              end
            end
          end
        end, bufnr)

      if not ok2 then cb({}) end
    end, bufnr)

  if not ok1 then cb({}) end
end

-- ─── Metodi propri del buffer ──────────────────────────────

local function collect_own_methods(symbols)
  local own = {}
  local function walk(syms)
    for _, sym in ipairs(syms or {}) do
      if sym.kind == "Class" then
        own[sym.name] = {}
        for _, ch in ipairs(sym.children or {}) do
          if ch.kind == "Method" or ch.kind == "Function" then
            own[sym.name][ch.name] = true
          end
        end
        walk(sym.children)
      end
    end
  end
  walk(symbols)
  return own
end

-- ─── Cerca riga classe nell'aerial buffer ──────────────────

local function find_class_row(aerial_bufnr, class_name)
  local escaped = vim.pesc(class_name)
  local lines   = vim.api.nvim_buf_get_lines(aerial_bufnr, 0, -1, false)
  for i, line in ipairs(lines) do
    if line:find(escaped) then return i - 1 end  -- 0-based
  end
  return nil
end

-- ─── Aggiornamento virtual lines ──────────────────────────

local function update_aerial(aerial_bufnr, source_bufnr)
  if not vim.api.nvim_buf_is_valid(aerial_bufnr) then return end
  if not vim.api.nvim_buf_is_valid(source_bufnr) then return end

  local client = find_hierarchy_client(source_bufnr)
  if not client then return end

  local ok, aerial = pcall(require, "aerial")
  if not ok then return end

  local symbols = aerial.get_symbols(source_bufnr)
  if not symbols or vim.tbl_isempty(symbols) then return end

  vim.api.nvim_buf_clear_namespace(aerial_bufnr, NS, 0, -1)

  local own = collect_own_methods(symbols)
  lsp_cache[source_bufnr] = lsp_cache[source_bufnr] or {}

  local function apply_virt(aerial_row, parent_methods, class_name)
    if not aerial_row then return end
    local class_own  = own[class_name] or {}
    local virt_lines = {}

    for pname, methods in pairs(parent_methods) do
      for _, mname in ipairs(methods) do
        if not class_own[mname] then
          table.insert(virt_lines, {
            { "  \xe2\x86\xb3 " .. mname, "AerialInheritedMethod" },
            { "  [" .. pname .. "]",       "AerialInheritedMethodSource" },
          })
        end
      end
    end

    if not vim.tbl_isempty(virt_lines) then
      pcall(vim.api.nvim_buf_set_extmark, aerial_bufnr, NS,
        aerial_row, 0, {
          virt_lines       = virt_lines,
          virt_lines_above = false,
        })
    end
  end

  local function walk(syms)
    for _, sym in ipairs(syms or {}) do
      if sym.kind == "Class" then
        local key = sym.name .. "@" .. tostring(sym.lnum)

        if lsp_cache[source_bufnr][key] then
          local row = find_class_row(aerial_bufnr, sym.name)
          apply_virt(row, lsp_cache[source_bufnr][key], sym.name)
        else
          local _name, _key = sym.name, key
          local _lnum, _col = sym.lnum, sym.col
          fetch_parent_methods(client, source_bufnr, _lnum, _col,
            function(parent_methods)
              lsp_cache[source_bufnr][_key] = parent_methods
              vim.schedule(function()
                if not vim.api.nvim_buf_is_valid(aerial_bufnr) then return end
                local row = find_class_row(aerial_bufnr, _name)
                apply_virt(row, parent_methods, _name)
              end)
            end)
        end
      end
      walk(sym.children)
    end
  end
  walk(symbols)
end

-- ─── Hook per ogni aerial buffer ──────────────────────────

local registered = {}

local function register_aerial(aerial_bufnr, source_bufnr)
  if registered[aerial_bufnr] then return end
  registered[aerial_bufnr] = true
  src_to_aerial[source_bufnr] = aerial_bufnr

  local group = vim.api.nvim_create_augroup(
    "AerialInherited_" .. aerial_bufnr, { clear = true })

  -- Trigger primario: evento aerial dopo aggiornamento
  vim.api.nvim_create_autocmd("User", {
    group   = group,
    pattern = "AerialTreeUpdateComplete",
    callback = function(ev)
      -- L'evento e' sparato nel contesto del source buffer
      if ev.buf == source_bufnr then
        vim.defer_fn(function()
          update_aerial(aerial_bufnr, source_bufnr)
        end, 150)
      end
    end,
  })

  -- Fallback: TextChanged sull'aerial buffer
  vim.api.nvim_create_autocmd("TextChanged", {
    group  = group,
    buffer = aerial_bufnr,
    callback = function()
      vim.defer_fn(function()
        update_aerial(aerial_bufnr, source_bufnr)
      end, 150)
    end,
  })

  -- Prima esecuzione
  vim.defer_fn(function()
    update_aerial(aerial_bufnr, source_bufnr)
  end, 500)
end

-- ─── Setup ────────────────────────────────────────────────

function M.on_attach(source_bufnr)
  -- Cerca subito se c'e' gia' un aerial buffer aperto per questo source
  vim.defer_fn(function()
    local aerial_bufnr = find_aerial_bufnr(source_bufnr)
    if aerial_bufnr then
      register_aerial(aerial_bufnr, source_bufnr)
    end
  end, 100)
end

function M.setup()
  define_hl()

  vim.api.nvim_create_autocmd("ColorScheme", {
    group    = vim.api.nvim_create_augroup("AerialInherited_HL", { clear = true }),
    callback = define_hl,
  })

  -- FileType aerial: correlazione tramite finestra precedente
  vim.api.nvim_create_autocmd("FileType", {
    group   = vim.api.nvim_create_augroup("AerialInherited_FT", { clear = true }),
    pattern = "aerial",
    callback = function(args)
      local aerial_bufnr = args.buf

      -- Tentativo 1: variabile interna di aerial
      local source_bufnr = nil
      for _, varname in ipairs({ "aerial_source_buf", "aerial_source_bufnr" }) do
        local ok, val = pcall(vim.api.nvim_buf_get_var, aerial_bufnr, varname)
        if ok and val and vim.api.nvim_buf_is_valid(val) then
          source_bufnr = val
          break
        end
      end

      -- Tentativo 2: finestra precedente
      if not source_bufnr then
        local prev_win = vim.fn.win_getid(vim.fn.winnr("#"))
        if prev_win and prev_win ~= 0 then
          local prev_buf = vim.api.nvim_win_get_buf(prev_win)
          if prev_buf ~= aerial_bufnr
            and vim.bo[prev_buf].filetype ~= "aerial" then
            source_bufnr = prev_buf
          end
        end
      end

      if not source_bufnr or not vim.api.nvim_buf_is_valid(source_bufnr) then
        return
      end

      register_aerial(aerial_bufnr, source_bufnr)
    end,
  })

  -- Invalida cache al salvataggio / re-attach LSP
  vim.api.nvim_create_autocmd({ "BufWritePost", "LspAttach" }, {
    group    = vim.api.nvim_create_augroup("AerialInherited_Cache", { clear = true }),
    callback = function(ev) lsp_cache[ev.buf] = nil end,
  })
end

return M
