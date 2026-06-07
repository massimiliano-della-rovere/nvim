local km = require("keymaps")
-- ============================================================
-- plugins/dashboard.lua  --  Neovim 0.12 / 0.13-compatible
-- ============================================================
-- alpha-nvim: schermata iniziale con file recenti (startify).
--
-- OPZIONI WINDOW-LOCAL PER IL FILETYPE "alpha":
-- number, relativenumber, signcolumn, statuscolumn sono opzioni
-- WINDOW-local (non buffer-local). Se impostate in un FileType
-- autocmd rimangono sulla finestra anche dopo aver cambiato
-- buffer, propagandosi ai file successivi.
--
-- Soluzione: salvare i valori correnti PRIMA di sovrascriverli
-- e ripristinarli esattamente su BufLeave tramite vim.wo[win].
-- vim.wo[win].opt legge/scrive la finestra specifica per id,
-- garantendo che il ripristino avvenga sulla finestra giusta
-- anche se il cursore si e' spostato altrove.
-- ============================================================

return {

  {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha     = require("alpha")
      local dashboard = require("alpha.themes.startify")
      alpha.setup(dashboard.config)

      vim.keymap.set("n", km.dashboard, "<CMD>Alpha<CR>",
        { desc = "Dashboard: show" })

      -- ── Opzioni estetiche per il buffer alpha ─────────────
      vim.api.nvim_create_autocmd("FileType", {
        group   = vim.api.nvim_create_augroup("AlphaDashboard", { clear = true }),
        pattern = "alpha",
        callback = function(args)
          local win = vim.api.nvim_get_current_win()

          -- Salva i valori CORRENTI della finestra prima di
          -- modificarli, cosi' il ripristino e' esatto
          -- indipendentemente da cosa imposta set_options.lua
          -- o statuscol.nvim nel frattempo.
          local saved = {
            number         = vim.wo[win].number,
            relativenumber = vim.wo[win].relativenumber,
            signcolumn     = vim.wo[win].signcolumn,
            statuscolumn   = vim.wo[win].statuscolumn,
            cursorline     = vim.wo[win].cursorline,
            cursorcolumn   = vim.wo[win].cursorcolumn,
            foldcolumn     = vim.wo[win].foldcolumn,
            list           = vim.wo[win].list,
          }

          -- Applica le opzioni silenziose per il dashboard
          vim.wo[win].number         = false
          vim.wo[win].relativenumber = false
          vim.wo[win].signcolumn     = "no"
          vim.wo[win].statuscolumn   = ""
          vim.wo[win].cursorline     = false
          vim.wo[win].cursorcolumn   = false
          vim.wo[win].foldcolumn     = "0"
          vim.wo[win].list           = false   -- nasconde listchars (¶ · ecc.)

          -- Ripristina quando si lascia il buffer alpha.
          -- once=true: l'alpha di norma si apre una sola volta;
          -- se rieseguito (:Alpha) il FileType riscatta di nuovo.
          vim.api.nvim_create_autocmd("BufLeave", {
            group    = vim.api.nvim_create_augroup(
                         "AlphaRestore_" .. args.buf, { clear = true }),
            buffer   = args.buf,
            once     = true,
            callback = function()
              -- Verifica che la finestra sia ancora valida
              -- (potrebbe essere stata chiusa nel frattempo)
              if not vim.api.nvim_win_is_valid(win) then return end
              vim.wo[win].number         = saved.number
              vim.wo[win].relativenumber = saved.relativenumber
              vim.wo[win].signcolumn     = saved.signcolumn
              vim.wo[win].statuscolumn   = saved.statuscolumn
              vim.wo[win].cursorline     = saved.cursorline
              vim.wo[win].cursorcolumn   = saved.cursorcolumn
              vim.wo[win].foldcolumn     = saved.foldcolumn
              vim.wo[win].list           = saved.list
            end,
          })
        end,
      })
    end,
  },

}
