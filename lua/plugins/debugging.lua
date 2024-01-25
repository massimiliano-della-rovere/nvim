local ensure_installed = {
  "bash-debug-adapter",
  "debugpy",
}

local dap_ui_symbols = {
  icons = { expanded = "🞃", collapsed = "🞂", current_frame = "→" },
  controls = {
    icons = {
      pause = "⏸",
      play = "⯈",
      step_into = "↴",
      step_over = "↷",
      step_out = "↑",
      step_back = "↶",
      run_last = "🗘",
      terminate = "🕱",
      disconnect = "⏻"
    }
  }
}

return {

  -- debug adapter
  {
    -- https://github.com/mfussenegger/nvim-dap
    "mfussenegger/nvim-dap",
    dependencies = {
      -- Installs the debug adapters for you
      "williamboman/mason.nvim",

      {
        "jay-babu/mason-nvim-dap.nvim",
        config = function()
          require("mason-nvim-dap").setup({
            -- Makes a best effort to setup the various debuggers with
            -- reasonable debug configurations
            automatic_installation = true,

            -- You"ll need to check that you have the required things installed
            -- online, please don"t ask me how to install them :)
            ensure_installed = ensure_installed,

            -- You can provide additional configuration to the handlers,
            -- see mason-nvim-dap README for more information
            handlers = {},
          })
        end,
      },

    },
    config = function()
      local dap = require("dap")
      require("debugging_bash_debug_adapter").configure_bashdb(dap)
      require("debugging_debugpy").configure_debugpy(dap)

      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Debug: Start/Continue" })
      vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Debug: Step Into" })
      vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Debug: Run Last" })
      vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "Debug: Step Out" })
      vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Debug: Open REPL" })
      vim.keymap.set("n", "<leader>dv", dap.step_over, { desc = "Debug: Step Over" })
    end,
  },

  -- debug adapter UI: Creates a beautiful debugger UI
  {
    -- https://github.com/rcarriga/nvim-dap-ui
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()
      require("dapui").setup(dap_ui_symbols)

      dap.listeners.after.event_initialized.dapui_config = dapui.open
      dap.listeners.before.attach.dapui_config = dapui.open
      dap.listeners.before.launch.dapui_config = dapui.open
      dap.listeners.before.event_terminated.dapui_config = dapui.close
      dap.listeners.before.event_exited.dapui_config = dapui.close

      vim.keymap.set("n", "<leader>dC", dapui.close, { desc = "DAP UI: Close" })
      vim.keymap.set("n", "<leader>dO", dapui.open, { desc = "DAP UI: Open" })
      vim.keymap.set("n", "<leader>dT", dapui.toggle, { desc = "DAP UI: Toggle" })

      local widgets = require("dap.ui.widgets")

      local function show(what)
        return function()
          widgets.centered_float(widgets[what])
        end
      end

      vim.keymap.set("n", "<leader>dh", widgets.hover, { desc = "Debug: Hover" })
      vim.keymap.set("n", "<leader>dp", widgets.preview, { desc = "Debug: Preview" })
      vim.keymap.set("n", "<leader>df", show("frames"), { desc = "Debug: Frames" })
      vim.keymap.set("n", "<leader>ds", show("scopes"), { desc = "Debug: Scopes" })
    end,
  },

  -- error finder and grouper
  {
    -- https://github.com/folke/trouble.nvim
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local trouble = require("trouble")
      trouble.setup({})

      local trouble_toggle = trouble.toggle
      vim.keymap.set(
        "n", "<leader>xd",
        function() trouble_toggle("document_diagnostics") end,
        { desc = "Trouble: Document Diagnostics" })
      vim.keymap.set(
        "n", "<leader>xl",
        function() trouble_toggle("loclist") end,
        { desc = "Trouble: Location list" })
      vim.keymap.set(
        "n", "<leader>xq",
        function() trouble_toggle("quickfix") end,
        { desc = "Trouble: Quickfix list" })
      vim.keymap.set(
        "n", "<leader>xr",
        function() trouble_toggle("lsp_references") end,
        { desc = "Trouble: LSP References" })
      vim.keymap.set(
        "n", "<leader>xt",
        "<CMD>TodoTrouble<CR>",
        { desc = "Notes: view tags" })
      vim.keymap.set(
        "n", "<leader>xw",
        function() trouble_toggle("workspace_diagnostics") end,
        { desc = "Trouble: Workspace Diagnostics" })
      vim.keymap.set(
        "n", "<leader>xx",
        function() trouble_toggle() end,
        { desc = "Trouble: toggle" })
    end
  },

  -- Virtual text showing variable values during debug
  {
    -- https://github.com/theHamsta/nvim-dap-virtual-text
    "theHamsta/nvim-dap-virtual-text",
    config = function()
      require("nvim-dap-virtual-text").setup {
        enabled = true,                        -- enable this plugin (the default)
        enabled_commands = true,               -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
        highlight_changed_variables = true,    -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
        highlight_new_as_changed = true,      -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
        show_stop_reason = true,               -- show stop reason when stopped for exceptions
        commented = true,                     -- prefix virtual text with comment string
        only_first_definition = false,          -- only show virtual text at first definition (if there are multiple)
        all_references = true,                -- show virtual text on all all references of the variable (not only definitions)
        clear_on_continue = false,             -- clear virtual text on "continue" (might cause flickering when stepping)

        --- A callback that determines how a variable is displayed or whether it should be omitted
        display_callback = function(variable, buf, stackframe, node, options)
          if options.virt_text_pos == "inline" then
            return " = " .. variable.value
          else
            return variable.name .. " = " .. variable.value
          end
        end,
        -- position of virtual text, see `:h nvim_buf_set_extmark()`, default tries to inline the virtual text. Use 'eol' to set to end of line
        virt_text_pos = vim.fn.has "nvim-0.10" == 1 and "inline" or "eol",

        -- experimental features:
        all_frames = false,                    -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
        virt_lines = false,                    -- show virtual lines instead of virtual text (will flicker!)
        virt_text_win_col = nil                -- position the virtual text at a fixed window column (starting from the first text column) ,
        -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
      }
    end,
  },

}
