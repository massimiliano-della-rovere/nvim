return {
  -- dev icons / nerd fonts
  "nvim-tree/nvim-web-devicons",

  -- Window resize
  {
    "anuvyklack/windows.nvim",
    dependencies = {
      "anuvyklack/middleclass",
      "anuvyklack/animation.nvim"
    },
    config = function()
      vim.opt.winwidth = 10
      vim.opt.winminwidth = 10
      vim.opt.equalalways = false

      require("windows").setup()

      vim.keymap.set("n", "<C-w>z", ":WindowsMaximize<CR>")
      vim.keymap.set("n", "<C-w>_", ":WindowsMaximizeVertically<CR>")
      vim.keymap.set("n", "<C-w>|", ":WindowsMaximizeHorizontally<CR>")
      vim.keymap.set("n", "<C-w>=", ":WindowsEqualize<CR>")
    end
  },

  -- navigation shortcuts
  "tpope/vim-unimpaired",

  -- quickfix list enhancements
  {
    "kevinhwang91/nvim-bqf",
    event = "VeryLazy",
    opts = {},
  },

  -- marks in the left column
  {
    "chentoast/marks.nvim",
    config = function()
      require("marks").setup()
    end
  },

  -- Useful plugin to show you pending keybinds.
  {
    "folke/which-key.nvim",
    config = function()
      -- document existing key chains
      require("which-key").register {
        ["<leader>c"] = { name = "[C]ode", _ = "which_key_ignore" },
        ["<leader>d"] = { name = "[D]ocument", _ = "which_key_ignore" },
        ["<leader>g"] = { name = "[G]it", _ = "which_key_ignore" },
        ["<leader>h"] = { name = "More git", _ = "which_key_ignore" },
        ["<leader>r"] = { name = "[R]ename", _ = "which_key_ignore" },
        ["<leader>s"] = { name = "[S]earch", _ = "which_key_ignore" },
        ["<leader>w"] = { name = "[W]orkspace", _ = "which_key_ignore" },
      }
      -- register which-key VISUAL mode
      -- required for visual <leader>hs (hunk stage) to work
      require("which-key").register({
        ["<leader>"] = { name = "VISUAL <leader>" },
        ["<leader>h"] = { "Git [H]unk" },
      }, { mode = "v" })
    end
  },

  -- rainbow matching delimiter symbols
  {
    "HiPhish/rainbow-delimiters.nvim",
    config = function()
      -- This module contains a number of default definitions
      local rainbow_delimiters = require "rainbow-delimiters"

      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
          vim = rainbow_delimiters.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
        },
        priority = {
          [""] = 110,
          lua = 210,
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }
    end
  },

  -- highlight vertical indent lines
  {
    -- Add indentation guides even on blank lines
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      local highlight = {
        "RainbowRed",
        "RainbowYellow",
        "RainbowBlue",
        "RainbowOrange",
        "RainbowGreen",
        "RainbowViolet",
        "RainbowCyan",
      }
      local hooks = require("ibl.hooks")
      -- create the highlight groups in the highlight setup hook, so they are reset
      -- every time the colorscheme changes
      hooks.register(
        hooks.type.HIGHLIGHT_SETUP,
        function()
          vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
          vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
          vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
          vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
          vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
          vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
          vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
        end
      )
      vim.g.rainbow_delimiters = { highlight = highlight }
      require("ibl").setup({ scope = { highlight = highlight } })
      hooks.register(
        hooks.type.SCOPE_HIGHLIGHT,
        hooks.builtin.scope_highlight_from_extmark)
    end
  },
}
