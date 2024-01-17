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
        "n", "<leader>ss",
        spectre.toggle,
        { desc = "Spectre: Toggle" })
      vim.keymap.set(
        "n", "<leader>sw",
        function()
          spectre.open_visual({select_word=true})
        end,
        { desc = "Spectre: Search current word" })
      vim.keymap.set(
        "v", "<leader>sw",
        "<esc><cmd>lua require('spectre').open_visual()<CR>",
        { desc = "Spectre: Search current word" })
      vim.keymap.set(
        "n", "<leader>sf",
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
    dependencies = {
      {"nvim-treesitter/nvim-treesitter", run = ":TSUpdate"},
    },
    ft = "qf",
    event = "VeryLazy",
    opts = {},
  },
}
