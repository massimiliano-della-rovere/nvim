-- lsp/jsonls.lua
-- Formato 0.12: restituisce una tabella di configurazione.
--
-- FIX rispetto a after/lsp/: la versione precedente usava
-- vim.fn.exists("*schemastore#schemas") che controlla una funzione
-- Vimscript inesistente. Ora usiamo pcall sul modulo Lua corretto.
-- Se schemastore.nvim non è installato i schemas rimangono nil
-- e il server funziona senza crash.

local schemas
local ok, schemastore = pcall(require, "schemastore")
if ok then
  schemas = schemastore.json.schemas()
end

return {
  filetypes    = { "json", "jsonc" },
  root_markers = { "package.json", ".git" },
  settings = {
    json = {
      schemas  = schemas,
      validate = { enable = true },
      format   = { enable = true },
    },
  },
}
