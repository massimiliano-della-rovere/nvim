-- ============================================================
-- plugins/agentic.lua  --  Neovim 0.12
-- ============================================================
-- Agentic.nvim: chat interface ACP per coding agent (Copilot CLI).
--
-- KEYMAPS  (<leader>z):
--   <leader>za   apri/mostra chat (toggle)
--   <leader>zn   nuova sessione
--   <leader>zr   ripristina sessione
--   <leader>zp   cambia provider ACP
--   <leader>zs   aggiungi selezione al contesto
--   <leader>zf   aggiungi file al contesto
--   <leader>zc   aggiungi contesto (selezione o file, smart)
--   <leader>zd   aggiungi diagnostica riga corrente
--   <leader>zb   aggiungi diagnostiche buffer
--   <leader>zx   interrompi generazione
--   <leader>zO   apri finestra (senza toggle)
--   <leader>zQ   chiudi finestra
--   <leader>zL   ruota layout finestra
-- ============================================================

local km = require("keymaps") -- prefissi centralizzati

return {
  "carlos-algms/agentic.nvim",

  --- @type agentic.PartialUserConfig
  opts = {
    provider = "copilot-acp",
  },

  config = function(_, opts)
    require("agentic").setup(opts)

    local agentic = require("agentic")

    vim.keymap.set("n", km.agentic .. "a", function()
      agentic.toggle()
    end, { desc = "Agentic: apri/mostra chat" })
    vim.keymap.set("n", km.agentic .. "n", function()
      agentic.new_session()
    end, { desc = "Agentic: nuova sessione" })
    vim.keymap.set("n", km.agentic .. "r", function()
      agentic.restore_session()
    end, { desc = "Agentic: ripristina sessione" })
    vim.keymap.set("n", km.agentic .. "p", function()
      agentic.switch_provider()
    end, { desc = "Agentic: cambia provider" })
    vim.keymap.set({ "n", "v" }, km.agentic .. "s", function()
      agentic.add_selection()
    end, { desc = "Agentic: aggiungi selezione al contesto" })
    vim.keymap.set("n", km.agentic .. "f", function()
      agentic.add_file()
    end, { desc = "Agentic: aggiungi file al contesto" })
    vim.keymap.set({ "n", "v" }, km.agentic .. "c", function()
      agentic.add_selection_or_file_to_context()
    end, { desc = "Agentic: aggiungi contesto (smart)" })
    vim.keymap.set("n", km.agentic .. "d", function()
      agentic.add_current_line_diagnostics()
    end, { desc = "Agentic: aggiungi diagnostica riga corrente" })
    vim.keymap.set("n", km.agentic .. "b", function()
      agentic.add_buffer_diagnostics()
    end, { desc = "Agentic: aggiungi diagnostiche buffer" })
    vim.keymap.set("n", km.agentic .. "x", function()
      agentic.stop_generation()
    end, { desc = "Agentic: interrompi generazione" })

    vim.keymap.set("n", km.agentic .. "O", function()
      agentic.open()
    end, { desc = "Agentic: apri finestra" })
    vim.keymap.set("n", km.agentic .. "Q", function()
      agentic.close()
    end, { desc = "Agentic: chiudi finestra" })
    vim.keymap.set("n", km.agentic .. "L", function()
      agentic.rotate_layout()
    end, { desc = "Agentic: ruota layout finestra" })
  end,
}
