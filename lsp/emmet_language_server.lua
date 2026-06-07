-- lsp/emmet_language_server.lua
return {
  filetypes = {
    "css", "eruby", "html", "htmldjango", "javascriptreact",
    "less", "pug", "sass", "scss", "svelte", "typescriptreact",
  },
  root_markers = { "package.json", ".git" },
  settings = {
    emmet = {
      showExpandedAbbreviation    = "always",
      showAbbreviationSuggestions = true,
      includeLanguages = {
        javascript = "html",
        typescript = "html",
      },
    },
  },
}
