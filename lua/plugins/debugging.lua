local ensure_installed = {
  "bash-debug-adapter",
  "debugpy",
}

return {

  -- debug adapter
  {
    -- https://github.com/mfussenegger/nvim-dap
    "mfussenegger/nvim-dap",
    dependencies = {
      -- Creates a beautiful debugger UI
      "rcarriga/nvim-dap-ui",

      -- Installs the debug adapters for you
      "williamboman/mason.nvim",
      "jay-babu/mason-nvim-dap.nvim",
    },
    config = function()
      local dap = require("dap")

      require("mason-nvim-dap").setup({
        -- Makes a best effort to setup the various debuggers with
        -- reasonable debug configurations
        automatic_setup = true,

        -- You can provide additional configuration to the handlers,
        -- see mason-nvim-dap README for more information
        handlers = {},

        -- You"ll need to check that you have the required things installed
        -- online, please don"t ask me how to install them :)
        ensure_installed = ensure_installed,
      })

      require("debugging_bash_debug_adapter").configure_bashdb(dap)
      require("debugging_debugpy").configure_debugpy(dap)

      vim.keymap.set("n", "<leader>db", dap.continue, { desc = "Debug: Set Breakpoint" })
      vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Debug: Start/Continue" })
      vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Debug: Step Into" })
      vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Debug: Run Last" })
      vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "Debug: Step Out" })
      vim.keymap.set("n", "<leader>dt", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Debug: Open REPL" })
      vim.keymap.set("n", "<leader>dv", dap.step_over, { desc = "Debug: Step Over" })

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

  -- debug adapter UI
  {
    -- https://github.com/rcarriga/nvim-dap-ui
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local dap, dapui = require("dap"), require("dapui")

      dapui.setup({
        -- Set icons to characters that are more likely to work in every terminal.
        --    Feel free to remove or use ones that you like more! :)
        --    Don"t feel like these are good choices.
        icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
        controls = {
          icons = {
            pause = "⏸",
            play = "▶",
            step_into = "⏎",
            step_over = "⏭",
            step_out = "⏮",
            step_back = "b",
            run_last = "▶▶",
            terminate = "⏹",
            disconnect = "⏏",
          },
        },
      })

      dap.listeners.after.event_initialized.dapui_config = dapui.open
      dap.listeners.before.attach.dapui_config = dapui.open
      dap.listeners.before.launch.dapui_config = dapui.open
      dap.listeners.before.event_terminated.dapui_config = dapui.close
      dap.listeners.before.event_exited.dapui_config = dapui.close

      vim.keymap.set("n", "<leader>dC", dapui.close, { desc = "DAP UI: Close" })
      vim.keymap.set("n", "<leader>dO", dapui.open, { desc = "DAP UI: Open" })
      vim.keymap.set("n", "<leader>dT", dapui.toggle, { desc = "DAP UI: Toggle" })
    end,
  },

  -- type checker
  {
    -- https://github.com/folke/neodev.nvim
    "folke/neodev.nvim",
    dependencies = { "rcarriga/nvim-dap-ui" },
    config = function()
      require("neodev").setup({
        library = { plugins = { "nvim-dap-ui" }, types = true },
      })
    end,
  },

  -- error finder and grouper
  {
    -- https://github.com/folke/trouble.nvim
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("trouble").setup({})

      local trouble_toggle = require("trouble").toggle
      vim.keymap.set("n", "<leader>xx", function() trouble_toggle() end, { desc = "Trouble: toggle" })
      vim.keymap.set("n", "<leader>xw", function() trouble_toggle("workspace_diagnostics") end, { desc = "Trouble: Workspace Diagnostics" })
      vim.keymap.set("n", "<leader>xd", function() trouble_toggle("document_diagnostics") end, { desc = "Trouble: Document Diagnostics" })
      vim.keymap.set("n", "<leader>xq", function() trouble_toggle("quickfix") end, { desc = "Trouble: Quickfix list" })
      vim.keymap.set("n", "<leader>xl", function() trouble_toggle("loclist") end, { desc = "Trouble: Location list" })
      vim.keymap.set("n", "<leader>xr", function() trouble_toggle("lsp_references") end, { desc = "Trouble: LSP References" })
    end
  },

}
