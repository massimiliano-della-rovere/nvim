-- lsp/dockerls.lua
return {
  filetypes    = { "dockerfile" },
  root_markers = { "Dockerfile", ".git" },
  settings = {
    docker = {
      languageserver = {
        formatter = { ignoreMultilineInstructions = true },
      },
    },
  },
}
