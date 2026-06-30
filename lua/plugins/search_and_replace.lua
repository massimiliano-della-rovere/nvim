local km = require("keymaps") -- prefissi centralizzati
return {
  -- search and replace using popup window
  {
    -- https://github.com/nvim-pack/nvim-spectre
    "nvim-pack/nvim-spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local spectre = require("spectre")
      spectre.setup({ is_block_ui_break = true })

      vim.keymap.set(
        "n", km.search .. "s",
        spectre.toggle,
        { desc = "Spectre: Toggle" })
      vim.keymap.set(
        "n", km.search .. "w",
        function()
          spectre.open_visual({select_word=true})
        end,
        { desc = "Spectre: Search current word" })
      vim.keymap.set(
        "v", km.search .. "w",
        "<esc><cmd>lua require('spectre').open_visual()<CR>",
        { desc = "Spectre: Search current word" })
      vim.keymap.set(
        "n", km.search .. "f",
        function()
          spectre.open_file_search({select_word=true})
        end,
        { desc = "Spectre: Search on current file" })
    end,
  },

  -- improved search, add, delete, swap using regex
  {
    -- https://github.com/tpope/vim-abolish
    "tpope/vim-abolish",
  },

  -- improved quickfix window with preview
  {
    -- https://github.com/kevinhwang91/nvim-bqf
    "kevinhwang91/nvim-bqf",
    -- highlighting nel preview richiede solo il parser installato
    -- (tree-sitter-manager.nvim in treesitter.lua), non un plugin
    ft = "qf",
    event = "VeryLazy",
    opts = {},
  },
}
