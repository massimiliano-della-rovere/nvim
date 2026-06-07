-- lsp/html.lua
return {
  filetypes    = { "html", "htmldjango", "handlebars" },
  root_markers = { "package.json", ".git" },
  settings = {
    html = {
      format = { wrapLineLength = 120, unformatted = "wbr" },
      hover  = { documentation = true, references = true },
    },
  },
  init_options = {
    provideFormatter  = true,
    embeddedLanguages = { css = true, javascript = true },
    configurationSection = { "html", "css", "javascript" },
  },
}
