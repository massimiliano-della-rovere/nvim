vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- [[ Basic Keymaps ]]

-- navigate through buffer list
  vim.keymap.set(
    "n", "<M-l>",
    "<CMD>bnext<CR>",
    { noremap = true, desc = "Next Buffer" })
  vim.keymap.set(
    "n", "<M-h>",
    "<CMD>bprev<CR>",
    { noremap = true, desc = "Prev Buffer" })
  vim.keymap.set(
    "n", "<M-k>",
    "<CMD>bprev<CR>",
    { noremap = true, desc = "Prev Buffer" })
  vim.keymap.set(
    "n", "<M-j>",
    "<CMD>bnext<CR>",
    { noremap = true, desc = "Next Buffer" })

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set(
  { "n", "v" }, "<Space>",
  "<Nop>",
  { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set(
  "n", "k", 
  "v:count == 0 ? 'gk' : 'k'",
  { expr = true, silent = true })
vim.keymap.set(
  "n", "j",
  "v:count == 0 ? 'gj' : 'j'",
  { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set(
  "n", "[d",
  vim.diagnostic.goto_prev,
  { desc = "Go to previous diagnostic message" })
vim.keymap.set(
  "n", "]d",
  vim.diagnostic.goto_next,
  { desc = "Go to next diagnostic message" })
vim.keymap.set(
  "n", "<leader>e",
  vim.diagnostic.open_float,
  { desc = "Open floating diagnostic message" })
vim.keymap.set(
  "n", "<leader>q",
  vim.diagnostic.setloclist,
  { desc = "Open diagnostics list" })

-- make Y do what is expected to do
vim.keymap.set(
  "n", "Y",
  "y$",
  { desc = "Copy line from the cursor position till the end" })

-- configuration file
vim.keymap.set(
  "n", "<leader>ve",
  ":edit ~/.config/nvim/init.lua<cr>",
  { desc = "N[V]im [E]dit configuration" })
vim.keymap.set(
  "n", "<leader>vs",
  ":source ~/.config/nvim/init.lua<cr>",
  { desc = "N[V]im [S]ave configuration"})
