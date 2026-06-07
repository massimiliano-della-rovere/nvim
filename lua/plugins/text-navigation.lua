-- ============================================================
-- plugins/text-navigation.lua  --  Neovim 0.12 / 0.13-compatible
-- ============================================================
-- nvim-ufo: folding avanzato con anteprima del contenuto piegato.
-- Le foldingRange capabilities sono iniettate globalmente da
-- mason_lsp.lua tramite vim.lsp.config("*", { capabilities = ... }).
-- Il keymap K usa vim.lsp.buf.hover() con bordo esplicito,
-- forma idiomatica 0.12+ senza vim.lsp.handlers.*.
-- ============================================================

local km = require("keymaps") -- prefissi centralizzati
local BORDER = "single"

local function folded_lines_indicator(virtText, lnum, endLnum, width, truncate)
  local newVirtText = {}
  local suffix = (" \xef\x80\x82 %d "):format(endLnum - lnum) -- nf-fa-angle_down
  local sufWidth = vim.fn.strdisplaywidth(suffix)
  local targetWidth = width - sufWidth
  local curWidth = 0
  for _, chunk in ipairs(virtText) do
    local chunkText = chunk[1]
    local chunkWidth = vim.fn.strdisplaywidth(chunkText)
    if targetWidth > curWidth + chunkWidth then
      table.insert(newVirtText, chunk)
    else
      chunkText = truncate(chunkText, targetWidth - curWidth)
      local hlGroup = chunk[2]
      table.insert(newVirtText, { chunkText, hlGroup })
      chunkWidth = vim.fn.strdisplaywidth(chunkText)
      if curWidth + chunkWidth < targetWidth then
        suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
      end
      break
    end
    curWidth = curWidth + chunkWidth
  end
  table.insert(newVirtText, { suffix, "MoreMsg" })
  return newVirtText
end

return {

  -- ── Shortcut navigazione ([], ]b, ]q …) ──────────────────
  "tpope/vim-unimpaired",

  -- ── Folding avanzato ─────────────────────────────────────
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    config = function()
      local ufo = require("ufo")

      vim.keymap.set("n", "zR", ufo.openAllFolds, { desc = "UFO: open all folds" })
      vim.keymap.set("n", "zM", ufo.closeAllFolds, { desc = "UFO: close all folds" })
      vim.keymap.set("n", "zr", ufo.openFoldsExceptKinds, { desc = "UFO: open except kinds" })
      vim.keymap.set("n", "zm", ufo.closeFoldsWith, { desc = "UFO: close with" })

      -- K: peek fold se piegato, altrimenti hover LSP con bordo.
      -- Il bordo e' passato direttamente: forma idiomatica 0.12+.
      vim.keymap.set("n", "K", function()
        local winid = ufo.peekFoldedLinesUnderCursor()
        if not winid then
          vim.lsp.buf.hover({ border = BORDER })
        end
      end, { desc = "UFO: peek fold / LSP hover" })

      ufo.setup({ fold_virt_text_handler = folded_lines_indicator })
    end,
  },

  -- ============================================================
  -- folke/flash.nvim  --  navigazione rapida con label
  -- ============================================================
  -- Rimpiazzo moderno di hop.nvim e leap.nvim.
  -- Etichetta le posizioni raggiungibili con 1-2 caratteri
  -- mentre usi / o s. Integrazione con Treesitter per selezionare
  -- nodi sintattici.
  --
  -- TASTI (normal/visual/operator-pending mode):
  --   s         jump: cerca e salta con label
  --   S         treesitter: seleziona un nodo con label
  --   r         remote:  operator-pending su posizione remota
  --   R         treesitter search: operator-pending
  --   <C-s>     cmdline: toggle flash durante /
  -- ============================================================
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    config = function()
      require("flash").setup({
        labels = "asdfghjklqwertyuiopzxcvbnm",
        search = {
          mode = "fuzzy",
          incremental = false,
        },
        jump = { autojump = true },
        label = {
          uppercase = false,
          after = true,
          before = false,
          style = "overlay",
          rainbow = { enabled = true, shade = 5 },
          min_pattern_length = 0,
        },
        highlight = {
          backdrop = true,
          matches = true,
          priority = 5000,
          groups = {
            match = "FlashMatch",
            current = "FlashCurrent",
            backdrop = "FlashBackdrop",
            label = "FlashLabel",
          },
        },
        modes = {
          -- s: jump diretto
          search = { enabled = false }, -- non sovrascrive / automaticamente
          char = {
            enabled = true,
            jump_labels = false, -- non interferisce con f/t/F/T normali
            multi_line = true,
          },
          treesitter = {
            labels = "abcdefghijklmnopqrstuvwxyz",
            jump = { pos = "range", autojump = false },
            label = { before = true, after = true, style = "inline" },
          },
          treesitter_search = {
            jump = { pos = "range" },
            animate = false,
            remote_op = { restore = true, motion = true },
          },
        },
      })

      -- Tasti standard raccomandati da flash.nvim
      -- `s` è libero perché nvim-surround ha no_normal_mappings = true
      vim.keymap.set({ "n" }, km.flash .. "s", function()
        require("flash").jump()
      end, { desc = "Flash: jump" })
      vim.keymap.set({ "x", "o" }, "s", function()
        require("flash").jump()
      end, { desc = "Flash: jump" })
      vim.keymap.set({ "n" }, km.flash .. "S", function()
        require("flash").jump()
      end, { desc = "Flash: jump" })
      vim.keymap.set({ "x", "o" }, "S", function()
        require("flash").treesitter()
      end, { desc = "Flash: treesitter select" })
      vim.keymap.set("o", "r", function()
        require("flash").remote()
      end, { desc = "Flash: remote (operator)" })
      vim.keymap.set({ "o", "x" }, "R", function()
        require("flash").treesitter_search()
      end, { desc = "Flash: treesitter search" })
      vim.keymap.set("c", "<C-s>", function()
        require("flash").toggle()
      end, { desc = "Flash: toggle in /?" })
    end,
  },

  -- ============================================================
  -- ThePrimeagen/harpoon  (branch harpoon2)
  -- ============================================================
  -- Segna fino a 4 file "attivi" e salta tra essi con un tasto.
  -- Diverso da telescope/buffers: è per i file su cui stai
  -- lavorando *in questo momento*, non per la navigazione globale.
  --
  -- KEYMAPS  (<leader>H):
  --   <leader>Ha    aggiungi file corrente alla lista
  --   <leader>Hh    apri il menu harpoon (modifica lista)
  --   <leader>Hf    apri lista in Telescope
  --   <M-1..4>      salta al file 1/2/3/4 della lista
  --   <leader>H[    file precedente nella lista
  --   <leader>H]    file successivo nella lista
  -- ============================================================
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup({
        settings = {
          save_on_toggle = true,
          sync_on_ui_close = true,
        },
      })

      -- Add / menu
      vim.keymap.set("n", km.harpoon .. "a", function()
        harpoon:list():add()
      end, { desc = "Harpoon: add file" })
      vim.keymap.set("n", km.harpoon .. "h", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = "Harpoon: menu" })

      -- Jump to file 1-4
      for i = 1, 4 do
        vim.keymap.set("n", "<M-" .. i .. ">", function()
          harpoon:list():select(i)
        end, { desc = "Harpoon: file " .. i })
      end

      -- Navigate list
      vim.keymap.set("n", km.harpoon .. "[", function()
        harpoon:list():prev()
      end, { desc = "Harpoon: prev file" })
      vim.keymap.set("n", km.harpoon .. "]", function()
        harpoon:list():next()
      end, { desc = "Harpoon: next file" })

      -- Telescope picker
      vim.keymap.set("n", km.harpoon .. "f", function()
        local conf = require("telescope.config").values
        local items = harpoon:list().items
        local paths = vim.tbl_map(function(i)
          return i.value
        end, items)
        require("telescope.pickers")
          .new({}, {
            prompt_title = "Harpoon",
            finder = require("telescope.finders").new_table({ results = paths }),
            previewer = conf.file_previewer({}),
            sorter = conf.generic_sorter({}),
          })
          :find()
      end, { desc = "Harpoon: telescope picker" })
    end,
  },
}
