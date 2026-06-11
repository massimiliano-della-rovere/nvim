-- ============================================================
-- init.lua  –  Neovim 0.12 config  (migrated from 0.10.x)
-- ============================================================
-- Nota: vim.pack è ancora sperimentale in 0.12 e non supporta
-- lazy-loading. Si conserva Lazy.nvim che è ancora superiore.
-- ============================================================

local function download_lazy(path)
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    path,
  })
end

local function bootstrap_lazy()
  local path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  -- uv.fs_stat restituisce nil se il path non esiste (non lancia più errori in 0.12)
  if not vim.uv.fs_stat(path) then
    download_lazy(path)
  end
  vim.opt.rtp:prepend(path)
end

bootstrap_lazy()

require("set_leaders") -- deve venire prima di lazy.setup()

-- require("lsp")
require("lazy").setup({
  change_detection = { enabled = true },
  checker = { enabled = true, notify = false },
  spec = {
    { import = "plugins" },
  },
  ui = { border = "single", custom_keys = {} },
})

-- ordine deliberato: opzioni e keymap DOPO i plugin per evitare
-- che i plugin sovrascrivano impostazioni personali
require("set_options")
require("set_keymaps")
require("show_color_column")
require("highlight_on_yank")
require("highlight_unison_files")
require("oop_signs").setup()
