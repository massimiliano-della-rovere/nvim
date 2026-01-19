local function get_python_executable()
  local venv = os.getenv("VIRTUAL_ENV")
  if venv then
    return vim.fs.joinpath(venv, "bin", "python")
  else
    return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
  end
end


vim.notify("basedpyright")


return {
  cmd = { "basedpyright-langserver", "--stdio", "--verbose" },
  filetypes = { "python" },
  root_markers = {
    ".git",
    "pyproject.toml",
    "setup.py",
    "pyrightconfig.json"
  },
  settings = {
    python = get_python_executable(),
    basedpyright = {
      analysis = {
        autoImportCompletions = true,
        autoSearchPaths = true,
        diagnosticMode = "workspace",
        -- extraPaths = {},
        -- include = {},
        inlayHints = {
          genericTypes = true
        },
        logLevel = "Information",
        typeCheckingMode = "recommended",
      }
    }
  }
}
