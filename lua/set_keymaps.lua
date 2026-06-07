-- ============================================================
-- set_keymaps.lua  –  Neovim 0.12
-- ============================================================
-- Nota: in 0.12 Neovim aggiunge automaticamente questi mapping
-- globali LSP (attivi dopo LspAttach):
--   gra → code actions      gri → implementations
--   grn → rename            grr → references
--   grt → type definition   grx → run codelens
--   gO  → document symbols  Ctrl-S (insert) → signature help
-- Li teniamo come riferimento; i nostri <leader>l* li sovrascrivono.

-- ── Navigazione buffer ──────────────────────────────────────
vim.keymap.set("n", "<M-l>", "<CMD>bnext<CR>",  { noremap = true, desc = "Buffer: Next" })
vim.keymap.set("n", "<M-h>", "<CMD>bprev<CR>",  { noremap = true, desc = "Buffer: Prev" })
vim.keymap.set("n", "<M-j>", "<CMD>bnext<CR>",  { noremap = true, desc = "Buffer: Next" })
vim.keymap.set("n", "<M-k>", "<CMD>bprev<CR>",  { noremap = true, desc = "Buffer: Prev" })

-- ── Sposta righe su/giù ─────────────────────────────────────
for _, key in pairs({ "j", "Down" }) do
  vim.keymap.set("n", "<M-" .. key .. ">", ":move .+1<CR>==",      { noremap = true, desc = "Line: shift down" })
  vim.keymap.set("v", "<M-" .. key .. ">", ":move '>+1<CR>gv=gv",  { noremap = true, desc = "Selection: shift down" })
  vim.keymap.set("i", "<M-" .. key .. ">", ":move .+1<CR>==gi",    { noremap = true, desc = "Line: shift down" })
end
for _, key in pairs({ "k", "Up" }) do
  vim.keymap.set("n", "<M-" .. key .. ">", ":move .-2<CR>==",      { noremap = true, desc = "Line: shift up" })
  vim.keymap.set("v", "<M-" .. key .. ">", ":move '<-2<CR>gv=gv",  { noremap = true, desc = "Selection: shift up" })
  vim.keymap.set("i", "<M-" .. key .. ">", ":move .-2<CR>==gi",    { noremap = true, desc = "Line: shift up" })
end

-- ── Comportamento base ──────────────────────────────────────
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Word-wrap aware j/k
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Y copia fino a fine riga (coerente con D e C)
vim.keymap.set("n", "Y", "y$", { desc = "Copy to end of line" })

-- ── Ridimensiona finestre ────────────────────────────────────
vim.keymap.set("n", "<C-Up>",    "<C-W>1-", { desc = "Window: shorter" })
vim.keymap.set("n", "<C-Down>",  "<C-W>1+", { desc = "Window: taller" })
vim.keymap.set("n", "<C-Left>",  "<C-W>1<", { desc = "Window: narrower" })
vim.keymap.set("n", "<C-Right>", "<C-W>1>", { desc = "Window: wider" })
