-- lsp/bashls.lua
-- Formato 0.12: questo file restituisce una tabella di configurazione.
-- Viene caricato automaticamente da vim.lsp.enable("bashls").
return {
  filetypes    = { "sh", "bash" },
  root_markers = { ".git", ".bashrc", ".bash_profile" },
  settings = {
    bashIde = {
      globPattern                  = "*@(.sh|.inc|.bash|.command)",
      enableSourceErrorDiagnostics = true,
    },
  },
}
