-- ============================================================
-- keymaps.lua  --  Radici centralizzate dei gruppi di comandi
-- ============================================================
-- Ogni plugin legge i prefissi da qui con:
--   local km = require("keymaps")
--   vim.keymap.set("n", km.lsp .. "f", ...)
--
-- Per spostare un intero gruppo: modifica UNA riga qui.
-- Per spostare questo file: crea lua/mykeys.lua con lo stesso
-- contenuto, poi sostituisci require("keymaps") ovunque, oppure
-- fai puntare questo file al nuovo modulo con:
--   return require("mykeys")
-- ============================================================

local M = {}

-- ── Prefissi principali ──────────────────────────────────────
M.ai = "<leader>a" -- CodeCompanion  (Claude API)
M.db = "<leader>b" -- Database (dadbod) / Buffer (bufferline)
M.copilot = "<leader>c" -- CopilotChat    (GitHub Copilot)
M.colorscheme = "<leader>C" -- Temi / colorscheme
M.debug = "<leader>d" -- DAP debugger
M.emmet = "<leader>e" -- Emmet abbreviations
M.find = "<leader>f" -- Telescope find / search
M.flash = "<leader>F" -- Flash
M.git = "<leader>g" -- Git  (telescope + gitsigns)
M.fugitive = "<leader>h" -- vim-fugitive
M.harpoon = "<leader>H" -- Harpoon  (file marks)
M.dashboard = "<leader>i" -- Dashboard alpha
M.docker = "<leader>k" -- Docker
M.lsp = "<leader>l" -- LSP / code actions
M.lsp_hier = "<leader>lh" -- LSP / gerarchia OOP
M.notes = "<leader>n" -- Note / TODO / markdown
M.oil = "<leader>o" -- Oil file browser
M.rename = "<leader>r" -- Rename simboli
M.remote = "<leader>R" -- Remote SSH / sshfs
M.surround = "<leader>S" -- nvim-surround
M.search = "<leader>s" -- Spectre search & replace
M.treesj = "<leader>t" -- TreeSJ  (split / join)
M.test = "<leader>T" -- Neotest
M.view = "<leader>v" -- View  (telescope pickers)
M.workspace = "<leader>w" -- LSP workspace folders
M.trouble = "<leader>x" -- Trouble  (diagnostics list)

-- ── Helper: prefix + suffix ───────────────────────────────────
-- Uso: km.k("lsp", "f")  →  "<leader>lf"
function M.k(group, suffix)
  return (M[group] or group) .. (suffix or "")
end

return M
