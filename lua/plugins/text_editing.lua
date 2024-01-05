return {
  -- entire file text object ae/ie
  {
    "chrisgrieser/nvim-various-textobjs",
    lazy = true,
  },

  -- surrounding tokens ('"<> etc)
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        keymaps = {
          insert = "<C-g>Sa", -- add{symbol} Add a surrounding pair around the cursor (insert mode)
          insert_line = "<C-g>SA", -- add{symbol} Add a surrounding pair around the cursor, on new lines (insert mode)

          normal = "<leader>Sa", -- add{motion}{symbol} Add a surrounding pair around a motion (normal mode)
          normal_cur = "<leader>Sl", -- add{symbol} Add a surrounding pair around the current line (normal mode)
          normal_line = "<leader>SA", -- add{motion}{symbol} Add a surrounding pair around a motion, on new lines (normal mode)
          normal_cur_line = "<leader>SL", -- add{symbol} Add a surrounding pair around the current line, on new lines (normal mode)

          visual_line = "<leader>Sl", -- add{symbol} Add a surrounding pair around a visual selection
          visual = "<leader>SL", -- add{symbol} Add a surrounding pair around a visual selection, on new lines

          delete = "<leader>Sd", -- delete{symbol} Delete a surrounding pair

          change = "<leader>Sc", -- change{old_symbol}{new_symbol} Change a surrounding pair
          change_line = "<leader>SC", -- change{old_symbol}{new_symbol} Change a surrounding pair, putting replacements on new lines
        }
      })
    end
  },

  -- Split/Join tree-like structures
  {
    "Wansmer/treesj",
    -- keys = { "<space>m", "<space>j", "<space>s" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    cmd = { "TSJToggle", "TSJSplit", "TSJJoin" },
    config = function()
      local tsj = require("treesj")

      tsj.setup({ use_default_keymaps = false })

      -- For use default preset and it work with dot
      vim.keymap.set(
        "n", "<leader>tj",
        tsj.join,
        { desc = "[T]ree split/[J]oin", noremap = true } )
      -- For use default preset and it work with dot
      vim.keymap.set(
        "n", "<leader>ts",
        tsj.split,
        { desc = "[T]ree [S]plit/join", noremap = true } )
      -- For use default preset and it work with dot
      vim.keymap.set(
        "n", "<leader>tm",
        tsj.toggle,
        { desc = "[T]ree split/join shallow [T]oggle", noremap = true } )
      -- For extending default preset with `recursive = true`, but this doesn"t work with dot
      vim.keymap.set(
        "n", "<leader>tM",
        function()
          tsj.toggle({ split = { recursive = true } })
        end,
        { desc = "[T]ree split/join recursive [T]oggle", noremap = true } )
    end,
  },
}
