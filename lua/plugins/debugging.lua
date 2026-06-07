-- ============================================================
-- plugins/debugging.lua  --  Neovim 0.12 / 0.13-compatible
-- ============================================================
-- Stack DAP:
--   mfussenegger/nvim-dap        core DAP client
--   rcarriga/nvim-dap-ui         UI floating windows
--   theHamsta/nvim-dap-virtual-text  valori variabili inline
--   jay-babu/mason-nvim-dap      installa debug adapter via Mason
--   folke/trouble.nvim           lista diagnostics/references (API v3)
-- ============================================================

local km = require("keymaps") -- prefissi centralizzati
local ensure_installed = { "bash-debug-adapter", "debugpy" }

local dap_ui_symbols = {
  icons    = { expanded = "\xf0\x9f\x9e\x83", collapsed = "\xf0\x9f\x9e\x82", current_frame = "\xe2\x86\x92" },
  controls = {
    icons = {
      pause      = "\xe2\x8f\xb8",
      play       = "\xe2\xaf\x88",
      step_into  = "\xe2\x86\xb4",
      step_over  = "\xe2\x86\xb7",
      step_out   = "\xe2\x86\x91",
      step_back  = "\xe2\x86\xb6",
      run_last   = "\xf0\x9f\x97\x98",
      terminate  = "\xf0\x9f\x95\xb1",
      disconnect = "\xe2\x8f\xbb",
    },
  },
}

return {

  -- ── DAP core ─────────────────────────────────────────────
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "nvim-neotest/nvim-nio",
      -- mason-org/mason.nvim: nome corretto del repo post-trasferimento
      "mason-org/mason.nvim",
      {
        "jay-babu/mason-nvim-dap.nvim",
        config = function()
          require("mason-nvim-dap").setup({
            automatic_installation = true,
            ensure_installed       = ensure_installed,
            handlers               = {},
          })
        end,
      },
    },
    config = function()
      local dap = require("dap")
      require("debugging_bash_debug_adapter").configure_bashdb(dap)
      require("debugging_debugpy").configure_debugpy(dap)

      vim.keymap.set("n", km.debug .. "b", dap.toggle_breakpoint, { desc = "Debug: toggle breakpoint" })
      vim.keymap.set("n", km.debug .. "c", dap.continue,          { desc = "Debug: continue" })
      vim.keymap.set("n", km.debug .. "i", dap.step_into,         { desc = "Debug: step into" })
      vim.keymap.set("n", km.debug .. "l", dap.run_last,          { desc = "Debug: run last" })
      vim.keymap.set("n", km.debug .. "o", dap.step_out,          { desc = "Debug: step out" })
      vim.keymap.set("n", km.debug .. "r", dap.repl.open,         { desc = "Debug: REPL" })
      vim.keymap.set("n", km.debug .. "v", dap.step_over,         { desc = "Debug: step over" })
    end,
  },

  -- ── DAP UI ───────────────────────────────────────────────
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup(dap_ui_symbols)

      dap.listeners.after.event_initialized.dapui_config  = dapui.open
      dap.listeners.before.attach.dapui_config            = dapui.open
      dap.listeners.before.launch.dapui_config            = dapui.open
      dap.listeners.before.event_terminated.dapui_config  = dapui.close
      dap.listeners.before.event_exited.dapui_config      = dapui.close

      vim.keymap.set("n", km.debug .. "C", dapui.close,  { desc = "DAP UI: close" })
      vim.keymap.set("n", km.debug .. "O", dapui.open,   { desc = "DAP UI: open" })
      vim.keymap.set("n", km.debug .. "T", dapui.toggle, { desc = "DAP UI: toggle" })

      local w = require("dap.ui.widgets")
      vim.keymap.set("n", km.debug .. "h", w.hover,   { desc = "Debug: hover" })
      vim.keymap.set("n", km.debug .. "p", w.preview, { desc = "Debug: preview" })
      vim.keymap.set("n", km.debug .. "f",
        function() w.centered_float(w.frames) end, { desc = "Debug: frames" })
      vim.keymap.set("n", km.debug .. "s",
        function() w.centered_float(w.scopes) end, { desc = "Debug: scopes" })
    end,
  },

  -- ── Trouble: diagnostics / references / quickfix ─────────
  -- API v3: trouble.toggle({ mode = "..." })
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local trouble = require("trouble")
      trouble.setup({})

      local function toggle(mode)
        return function() trouble.toggle({ mode = mode }) end
      end

      vim.keymap.set("n", km.trouble .. "d", toggle("diagnostics"),    { desc = "Trouble: diagnostics" })
      vim.keymap.set("n", km.trouble .. "l", toggle("loclist"),         { desc = "Trouble: loclist" })
      vim.keymap.set("n", km.trouble .. "q", toggle("quickfix"),       { desc = "Trouble: quickfix" })
      vim.keymap.set("n", km.trouble .. "r", toggle("lsp_references"), { desc = "Trouble: LSP references" })
      vim.keymap.set("n", km.trouble .. "t", "<CMD>TodoTrouble<CR>",   { desc = "Trouble: TODOs" })
      vim.keymap.set("n", km.trouble .. "w", toggle("diagnostics"),    { desc = "Trouble: workspace diag." })
      vim.keymap.set("n", km.trouble .. "x", function() trouble.toggle() end, { desc = "Trouble: toggle" })
    end,
  },

  -- ── Virtual text valori variabili durante il debug ────────
  {
    "theHamsta/nvim-dap-virtual-text",
    config = function()
      require("nvim-dap-virtual-text").setup({
        enabled                     = true,
        enabled_commands            = true,
        highlight_changed_variables = true,
        highlight_new_as_changed    = true,
        show_stop_reason            = true,
        commented                   = true,
        only_first_definition       = false,
        all_references              = true,
        clear_on_continue           = false,
        display_callback = function(variable, _, _, _, options)
          if options.virt_text_pos == "inline" then
            return " = " .. variable.value
          else
            return variable.name .. " = " .. variable.value
          end
        end,
        virt_text_pos = "inline",
        all_frames    = false,
        virt_lines    = false,
      })
    end,
  },

}
