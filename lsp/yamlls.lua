-- lsp/yamlls.lua
local schemas
local ok, schemastore = pcall(require, "schemastore")
if ok then
  schemas = schemastore.yaml.schemas()
end

return {
  filetypes    = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
  root_markers = { ".git" },
  settings = {
    yaml = {
      keyOrdering = false,
      format      = { enable = true },
      validate    = true,
      hover       = true,
      completion  = true,
      -- Usa schemastore.nvim se disponibile, altrimenti il catalogo online
      schemas  = schemas,
      schemaStore = {
        enable = schemas == nil,   -- abilita solo se il plugin non è caricato
        url    = "https://www.schemastore.org/api/json/catalog.json",
      },
    },
  },
}
