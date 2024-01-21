return {

  -- Detect tabstop and shiftwidth automatically
  -- https://github.com/tpope/vim-sleuth
  "tpope/vim-sleuth",

  -- "gc"/"gb" to comment visual regions/lines
  {
    -- https://github.com/numToStr/Comment.nvim
    "numToStr/Comment.nvim",
    opts = {},
  },

  -- highlight word under the cursor
  {
    -- https://github.com/RRethy/vim-illuminate
    "RRethy/vim-illuminate",
    config = function()
      vim.api.nvim_set_hl(0, "IlluminatedWordText", { underdouble = true, bold = true })
      vim.api.nvim_set_hl(0, "IlluminatedWordRead", { underdouble = true, bold = true })
      vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { underdouble = true, bold = true })
      require("illuminate").configure()
    end,
  },

  -- highlight match symbol area
  -- must be after colorscheme
  {
    -- https://github.com/rareitems/hl_match_area.nvim
    "rareitems/hl_match_area.nvim",
    config = function()
      require("hl_match_area").setup({
        highlight_in_insert_mode = true, -- should highlighting also be done in insert mode
        delay = 100, -- delay before the highglight
      })
      if not vim.startswith(vim.g.colors_name, "kanagawa") then
        vim.api.nvim_set_hl(0, "MatchArea", { bg = "#4A2400" })
      else
        vim.api.nvim_set_hl(0, 'MatchArea', { bg = "#303030" })
      end
    end
  },

  -- rainbow matching delimiter symbols
  {
    -- http://github.com/HiPhish/rainbow-delimiters.nvim
    "HiPhish/rainbow-delimiters.nvim",
    config = function()
      -- This module contains a number of default definitions
      local rainbow_delimiters = require("rainbow-delimiters")

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
    -- https://github.com/lukas-reineke/indent-blankline.nvim
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
      require("ibl").setup({
        scope = { highlight = highlight, },
      })
      hooks.register(
        hooks.type.SCOPE_HIGHLIGHT,
        hooks.builtin.scope_highlight_from_extmark)
    end
  },

  -- code outline
  {
    -- https://github.com/stevearc/aerial.nvim
    "stevearc/aerial.nvim",
    -- Optional dependencies
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons"
    },
    config = function()
      require("aerial").setup({
        default_direction = "prefer_right",
        open_automatic = false,
        show_guides = true,

        filter_kind = false,

        autojump = true,
        highlight_on_hover = true,
        manager_folds = true,
      })

      vim.keymap.set(
        "n", "<leader>ld",
        "<CMD>AerialToggle<CR>",
        { desc = "Aerial: Document Symbols" })

      for _, key_combination in ipairs({"ls", "vs"}) do
        vim.keymap.set(
          "n", "<leader>" .. key_combination,
          function()
            require("telescope").load_extension("aerial")
            require("telescope").extensions.aerial.aerial()
          end,
          { desc = "Aerial: Document Symbols" })
      end

      vim.keymap.set(
        "n", "<leader>ln",
        "<CMD>AerialNavToggle<CR>",
        { desc = "Aerial: Toggle Nav" })
    end,
  },

  -- Neovim setup for init.lua and plugin development with full signature help, docs and completion for the nvim lua API.
  {
    -- https://github.com/folke/neodev.nvim
    "folke/neodev.nvim",
    dependencies = {
      -- Creates a beautiful debugger UI
      -- already in debugging.lua
      "rcarriga/nvim-dap-ui",
    },
    config = function()
      require("neodev").setup({
        library = { plugins = { "nvim-dap-ui" }, types = true },
      })
    end,
  },

}
