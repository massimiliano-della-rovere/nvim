-- debugging_debugpy.lua
local home = os.getenv("HOME")
local virtualenvs_dir = home .. "/.virtualenvs"
local debugpy_venv = virtualenvs_dir .. "/debugpy"
local default_python = debugpy_venv .. "/bin/python"


local function install_debugpy_venv_if_necessary()
  if vim.fn.isdirectory(virtualenvs_dir) == 0 then
    vim.fn.mkdir(virtualenvs_dir, "p")
  end

  if vim.fn.isdirectory(debugpy_venv) == 0 then
    -- Fix: usa vim.notify (sempre disponibile) invece di require("notify")
    -- che potrebbe non essere ancora caricato quando questo modulo viene richiesto.
    local current_dir = vim.fn.chdir(virtualenvs_dir)
    if current_dir ~= "" then
      vim.notify(
        "creating the " .. debugpy_venv .. " venv, this could take a while.",
        vim.log.levels.INFO)
      vim.fn.execute("! python3 -m venv debugpy")
      vim.fn.execute("! debugpy/bin/python -m pip install debugpy")
    else
      vim.notify(
        "could not create the " .. virtualenvs_dir .. " dir!",
        vim.log.levels.ERROR)
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
        options = { source_filetype = "python" },
      })
    else
      cb({
        type = "executable",
        command = default_python,
        args = { "-m", "debugpy.adapter" },
        options = { source_filetype = "python" },
      })
    end
  end

  dap.configurations.python = {
    {
      type    = "python",
      request = "launch",
      name    = "Launch file",
      program = "${file}",
      pythonPath = function()
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
