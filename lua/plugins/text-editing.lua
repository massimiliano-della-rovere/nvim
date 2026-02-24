return {
  -- entire file text object gG
  {
    -- https://github.com/chrisgrieser/nvim-various-textobjs
    "chrisgrieser/nvim-various-textobjs",
    lazy = true,
  },

  -- surrounding tokens ('"<> etc)
  {
    -- https://github.com/kylechui/nvim-surround
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      vim.g.nvim_surround_no_normal_mappings = true
      require("nvim-surround").setup({})
      vim.keymap.set("i", "<C-g>Sa", "<Plug>(nvim-surround-insert)", {
        desc = "Add a surrounding pair around the cursor (insert mode)",
      })
      vim.keymap.set("i", "<C-g>SA", "<Plug>(nvim-surround-insert-line)", {
        desc = "Add a surrounding pair around the cursor, on new lines (insert mode)",
      })

      vim.keymap.set("n", "<leader>Sa", "<Plug>(nvim-surround-normal)", {
        desc = "Add a surrounding pair around a motion (normal mode)",
      })
      vim.keymap.set("n", "<leader>Sl", "<Plug>(nvim-surround-normal-cur)", {
        desc = "Add a surrounding pair around the current line (normal mode)",
      })
      vim.keymap.set("n", "<leader>SA", "<Plug>(nvim-surround-normal-line)", {
        desc = "Add a surrounding pair around a motion, on new lines (normal mode)",
      })
      vim.keymap.set("n", "<leader>SL", "<Plug>(nvim-surround-normal-cur-line)", {
        desc = "Add a surrounding pair around the current line, on new lines (normal mode)",
      })

      vim.keymap.set("x", "<leader>Sl", "<Plug>(nvim-surround-visual)", {
        desc = "Add a surrounding pair around a visual selection",
      })
      vim.keymap.set("x", "<leader>SL", "<Plug>(nvim-surround-visual-line)", {
        desc = "Add a surrounding pair around a visual selection, on new lines",
      })

      vim.keymap.set("n", "<leader>Sd", "<Plug>(nvim-surround-delete)", {
        desc = "Delete a surrounding pair",
      })

      vim.keymap.set("n", "<leader>Sc", "<Plug>(nvim-surround-change)", {
        desc = "Change a surrounding pair",
      })
      vim.keymap.set("n", "<leader>SC", "<Plug>(nvim-surround-change-line)", {
        desc = "Change a surrounding pair, putting replacements on new lines",
      })
    end
  },

  -- Split/Join tree-like structures
  {
    -- https://github.com/Wansmer/treesj
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
        { desc = "TreeSJ: Join", noremap = true } )
      -- For use default preset and it work with dot
      vim.keymap.set(
        "n", "<leader>ts",
        tsj.split,
        { desc = "TreeSJ: Split", noremap = true } )
      -- For use default preset and it work with dot
      vim.keymap.set(
        "n", "<leader>tm",
        tsj.toggle,
        { desc = "TreeSJ: shallow Toggle", noremap = true } )
      -- For extending default preset with `recursive = true`, but this doesn"t work with dot
      vim.keymap.set(
        "n", "<leader>tM",
        function()
          tsj.toggle({ split = { recursive = true } })
        end,
        { desc = "TreeSJ: recursive Toggle", noremap = true } )
    end,
  },

}
