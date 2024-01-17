local function configure_bashdb(dap)
  local data_dir = vim.fn.stdpath("data")
  local bash_da_dir = data_dir .. "/mason/packages/bash-debug-adapter"

  dap.adapters.bashdb = {
    type = "executable",
    command = bash_da_dir .. "/bash-debug-adapter",
    name = "bashdb",
  }

  dap.configurations.sh = {
    {
      type = "bashdb",
      request = "launch",
      name = "Launch file",
      showDebugOutput = true,
      pathBashdb = bash_da_dir .. "/extension/bashdb_dir/bashdb",
      pathBashdbLib = bash_da_dir .. "/extension/bashdb_dir",
      trace = true,
      file = "${file}",
      program = "${file}",
      cwd = "${workspaceFolder}",
      pathCat = "cat",
      pathBash = "/bin/bash",
      pathMkfifo = "mkfifo",
      pathPkill = "pkill",
      args = {},
      env = {},
      terminalKind = "integrated",
    }
  }
end


return { configure_bashdb = configure_bashdb }
