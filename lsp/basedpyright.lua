-- lsp/basedpyright.lua
-- Rileva automaticamente il pythonPath del virtualenv attivo.
local python_path
local venv = os.getenv("VIRTUAL_ENV")
if venv then
  python_path = venv .. "/bin/python"
end

return {
  cmd          = { "basedpyright-langserver", "--stdio" },
  filetypes    = { "python" },
  root_markers = {
    "pyrightconfig.json", "pyproject.toml",
    "setup.py", "setup.cfg", ".git",
  },
  settings = {
    python = {
      pythonPath = python_path,
    },
    basedpyright = {
      analysis = {
        autoImportCompletions = true,
        autoSearchPaths       = true,
        diagnosticMode        = "workspace",
        logLevel              = "Information",
        typeCheckingMode      = "recommended",
        inlayHints = {
          genericTypes        = true,
          variableTypes       = true,
          parameterTypes      = true,
          callArgumentNames   = true,
          functionReturnTypes = true,
        },
      },
    },
  },
}
