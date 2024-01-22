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

  -- move lines up- or down-ward
for _, key in pairs({ "j", "Down" }) do
  vim.keymap.set(
    "n", "<M-" .. key .. ">",
    ":move .+1<CR>==",
    { noremap = true, desc = "Shift line downward" })
  vim.keymap.set(
    "v", "<M-" .. key .. ">",
    ":move '>+1<CR>gv=gv",
    { noremap = true, desc = "Shift selection downward" })
  vim.keymap.set(
    "i", "<M-" .. key .. ">",
    ":move .+1<CR>==gi",
    { noremap = true, desc = "Shift line downward" })
end
for _, key in pairs({ "k", "Up" }) do
  vim.keymap.set(
    "n", "<M-" .. key .. ">",
    ":move .-2<CR>==",
    { noremap = true, desc = "Shift line upward" })
  vim.keymap.set(
    "i", "<M-" .. key .. ">",
    ":move .-2<CR>==gi",
    { noremap = true, desc = "Shift line upward" })
  vim.keymap.set(
    "v", "<M-" .. key .. ">",
    ":move <-2<CR>gv=gv",
    { noremap = true, desc = "Shift selection upward" })
end

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

-- make Y do what is expected to do
vim.keymap.set(
  "n", "Y",
  "y$",
  { desc = "Copy line from the cursor position till the end" })
