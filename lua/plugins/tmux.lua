return {
  -- tmux integration
  {
    -- https://github.com/christoomey/vim-tmux-navigator
    "christoomey/vim-tmux-navigator",
    config = function()
      vim.keymap.set(
        "n", "<c-h>",
        ":TmuxNavigateLeft<cr>",
        { desc = "Tmux Window Left" })
      vim.keymap.set(
        "n", "<c-j>",
        ":TmuxNavigateDown<cr>",
        { desc = "Tmux Window Down" })
      vim.keymap.set(
        "n", "<c-k>",
        ":TmuxNavigateUp<cr>",
        { desc = "Tmux Window Up" })
      vim.keymap.set(
        "n", "<c-l>",
        ":TmuxNavigateRight<cr>",
        { desc = "Tmux Window Right" })
    end
  }
}
