local home = os.getenv("HOME")
local virtualenvs_dir = home .. "/.virtualenvs"
local debugpy_venv = virtualenvs_dir .. "/debugpy"
local default_python = debugpy_venv .. "/bin/python"


local function install_debugpy_venv_if_necessary()
  if vim.fn.isdirectory(virtualenvs_dir) == 0 then
    vim.fn.mkdir(virtualenvs_dir, "p")
  end

  if vim.fn.isdirectory(debugpy_venv) == 0 then
    local notify = require("notify")
    local current_dir = vim.fn.chdir(virtualenvs_dir)
    if current_dir ~= "" then
      notify("creating the " .. debugpy_venv .. " venv, this could take a while.", "info")
      vim.fn.execute("! python3 -m venv debugpy")
      vim.fn.execute("! debugpy/bin/python -m pip install debugpy")
    else
      notify("could not create the " .. virtualenvs_dir .. " dir!", "error")
    end
  end
end


local function configure_debugpy(dap)
  dap.adapters.python = function(cb, config)
    if config.request == "attach" then
      ---@diagnostic disable-next-line: undefined-field
      local port = (config.connect or config).port
      ---@diagnostic disable-next-line: undefined-field
      local host = (config.connect or config).host or "127.0.0.1"
      cb({
        type = "server",
        port = assert(port, "`connect.port` is required for a python `attach` configuration"),
        host = host,
        options = {
          source_filetype = "python",
        },
      })
    else
      cb({
        type = "executable",
        command = default_python,
        args = { "-m", "debugpy.adapter" },
        options = {
          source_filetype = "python",
        },
      })
    end
  end

  dap.configurations.python = {
    {
      -- The first three options are required by nvim-dap
      type = "python", -- the type here established the link to the adapter definition: `dap.adapters.python`
      request = "launch",
      name = "Launch file",

      -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

      program = "${file}", -- This configuration will launch the current file if used.
      pythonPath = function()
        -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
        -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
        -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
        local cwd = vim.fn.getcwd()
        if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
          return cwd .. "/venv/bin/python"
        elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
          return cwd .. "/.venv/bin/python"
        elseif vim.fn.executable(default_python) == 1 then
          return default_python
        else
          return "/usr/bin/python"
        end
      end,
    },
  }
end


install_debugpy_venv_if_necessary()
return { configure_debugpy = configure_debugpy }
