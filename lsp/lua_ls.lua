-- lsp/lua_ls.lua  --  Neovim 0.12 / 0.13-compatible
--
-- lazydev.nvim (caricato in programming.lua) aggiunge automaticamente
-- il runtime di Neovim a lua_ls quando si apre un file Lua nella
-- config di Neovim, fornendo:
--   • tipi completi per vim.api.*, vim.fn.*, vim.lsp.*, ecc.
--   • completamento e hover per tutte le API Neovim
--   • nessun "undefined field" su vim.*
--
-- Per questo NON impostiamo workspace.library manualmente:
-- lazydev lo gestisce in modo incrementale e senza rallentare lo startup.
--
-- REQUISITO: lazydev.nvim deve essere caricato PRIMA che lua_ls si
-- attacchi al buffer. Con Lazy.nvim e ft = "lua" questo avviene
-- automaticamente perché lazydev è caricato al FileType "lua".

---
---@type vim.lsp.Config
return {
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
  settings = {
    Lua = {
      runtime = {
        -- LuaJIT è il runtime usato da Neovim
        version = "LuaJIT",
        pathStrict = false,
      },
      workspace = {
        ignoreDir = { ".git" },
        -- false: non chiedere conferma per librerie di terze parti
        -- (es. quando si apre un plugin con require())
        checkThirdParty = false,
        -- library NON impostato qui: lazydev.nvim inietta
        -- il runtime Neovim solo nei file della config Neovim,
        -- evitando di indicizzare tutto il runtime per ogni file .lua
      },
      diagnostics = {
        -- "vim" come global di fallback: protegge se lazydev
        -- non è ancora attivo (es. primo avvio prima dell'install)
        globals = { "vim" },
        unusedLocalExclude = { "_*" },
        -- Disabilita avvisi per campi sconosciuti nei moduli Neovim
        -- (some API fields are undocumented or version-dependent)
        disable = { "missing-fields" },
      },
      completion = {
        -- "Replace": sostituisce l'intera parola con lo snippet
        callSnippet = "Replace",
      },
      format = {
        enable = true,
        defaultConfig = {
          indent_style = "space",
          indent_size = "2",
        },
      },
      hint = {
        enable = true,
        arrayIndex = "Enable",
        await = true,
        paramName = "All",
        paramType = true,
        semicolon = "SameLine",
        setType = true,
      },
      codeLens = { enable = true },
      telemetry = { enable = false },
    },
  },
}
