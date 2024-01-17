return {

  -- theme(s)
  {
    -- https://github.com/rebelot/kanagawa.nvim
    "rebelot/kanagawa.nvim",
    priority = 1000,
    config = function()
      require("kanagawa").setup({
        dimInactive = true
      })
      vim.cmd.colorscheme("kanagawa-wave") -- kanagawa-dragon, kanagawa-lotus
    end
  },

  {
    -- catppuccin/nvim
    "catppuccin/nvim",
    priority = 1000,
    config = function()
      require("catppuccin").setup({})
    end
  },

}
