return {

  -- theme(s)
  {
    -- https://github.com/rebelot/kanagawa.nvim
    "rebelot/kanagawa.nvim",
    priority = 1000,
    config = function()
      require("kanagawa").setup({
        dimInactive = true,
        colors = {
          theme = {
            all = {
              ui = {
                bg_gutter = "none"
              }
            }
          }
        }
      })

      vim.cmd.colorscheme("kanagawa-wave") -- kanagawa-dragon, kanagawa-lotus

      vim.keymap.set("n", "<leader>ckw", function() vim.cmd.colorscheme("kanagawa-wave") end, { desc = "Colorscheme Kanagawa Wave (d)" })
      vim.keymap.set("n", "<leader>ckd", function() vim.cmd.colorscheme("kanagawa-dragon") end, { desc = "Colorscheme Kanagawa Dragon (d)" })
      vim.keymap.set("n", "<leader>ckl", function() vim.cmd.colorscheme("kanagawa-lotus") end, { desc = "Colorscheme Kanagawa Lotus (l)" })
    end
  },

  {
    -- catppuccin/nvim
    "catppuccin/nvim",
    priority = 1000,
    config = function()
      require("catppuccin").setup({})

      vim.keymap.set("n", "<leader>ccl", function() vim.cmd.colorscheme("catppuccin-latte") end, { desc = "Colorscheme Catppuccin Latte (l)" })
      vim.keymap.set("n", "<leader>ccM", function() vim.cmd.colorscheme("catppuccin-macchiato") end, { desc = "Colorscheme Catppuccin Macchiato (d)" })
      vim.keymap.set("n", "<leader>ccm", function() vim.cmd.colorscheme("catppuccin-mocha") end, { desc = "Colorscheme Catppuccin Mocha (d)" })
      vim.keymap.set("n", "<leader>ccf", function() vim.cmd.colorscheme("catppuccin-frappe") end, { desc = "Colorscheme Catppuccin Frappe (d)" })
    end
  },

  -- tokyonight
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        dim_inactive = true,
      })

      vim.keymap.set("n", "<leader>ctd", function() vim.cmd.colorscheme("tokyonight-day") end, { desc = "Colorscheme Tokyonight Day (l)" })
      vim.keymap.set("n", "<leader>ctm", function() vim.cmd.colorscheme("tokyonight-moon") end, { desc = "Colorscheme Tokyonight Moon (d)" })
      vim.keymap.set("n", "<leader>ctn", function() vim.cmd.colorscheme("tokyonight-night") end, { desc = "Colorscheme Tokyonight Night (d)" })
      vim.keymap.set("n", "<leader>cts", function() vim.cmd.colorscheme("tokyonight-storm") end, { desc = "Colorscheme Tokyonight Storm (d)" })
    end,
  },

  -- gruvbox
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("gruvbox").setup({
        dim_inactive = true,
      })

      vim.keymap.set(
        "n", "<leader>cgd",
        function()
          vim.o.background = "dark"
          vim.cmd.colorscheme("gruvbox")
        end,
        { desc = "Colorscheme Gruvbox (d)" })
      vim.keymap.set(
        "n", "<leader>cgl",
        function()
          vim.o.background = "light"
          vim.cmd.colorscheme("gruvbox")
        end,
        { desc = "Colorscheme Gruvbox (l)" })
    end,
  },

}
