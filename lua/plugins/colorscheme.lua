return {
  -- { 
  --   "catppuccin/nvim",
  --   config = function()
  --     vim.cmd.colorscheme("catppuccin")
  --   end,
  -- },
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    opts = { dimInactive = false },
    config = function()
      vim.cmd.colorscheme("kanagawa-wave") -- kanagawa-dragon, kanagawa-lotus
    end,
  },
  -- {
  --   "knghtbrd/tigrana",
  --   priority = 2000,
  --   config = function()
  --     vim.cmd.colorscheme("tigrana-256-dark")
  --   end
  -- },
  -- {
  --   -- Theme inspired by Atom
  --   "navarasu/onedark.nvim",
  --   priority = 1000,
  --   config = function()
  --     vim.cmd.colorscheme("onedark")
  --   end,
  -- },
}
