-- ============================================================
-- set_options.lua  --  Neovim 0.12 / 0.13-compatible
-- ============================================================

-- ── Indentazione: sempre spazi, mai tab ─────────────────────
-- Default globale: espandi i tab in spazi ovunque.
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

-- ── Per-filetype: larghezza corretta ─────────────────────────
-- FileType imposta la larghezza giusta per ogni linguaggio.
-- BufReadPost+schedule ri-impone expandtab DOPO vim-sleuth,
-- che viene caricato come plugin e registra il suo BufReadPost
-- più tardi (lo schedule() lo bypassa eseguendo nella iterazione
-- successiva del loop di eventi).
do
  local G = vim.api.nvim_create_augroup("AlwaysSpaces", { clear = true })

  local function spaces(sw)
    return function(ev)
      vim.bo[ev.buf].expandtab = true
      vim.bo[ev.buf].tabstop = sw
      vim.bo[ev.buf].softtabstop = sw
      vim.bo[ev.buf].shiftwidth = sw
    end
  end

  -- 4 spazi: Python (PEP 8)
  vim.api.nvim_create_autocmd("FileType", {
    group = G,
    pattern = { "python" },
    callback = spaces(4),
  })

  -- 2 spazi: tutto il codice e i formati dati
  vim.api.nvim_create_autocmd("FileType", {
    group = G,
    pattern = {
      "lua",
      "vim",
      "javascript",
      "typescript",
      "javascriptreact",
      "typescriptreact",
      "css",
      "scss",
      "less",
      "html",
      "htmldjango",
      "jinja",
      "xml",
      "svg",
      "json",
      "jsonc",
      "yaml",
      "toml",
      "sh",
      "bash",
      "zsh",
      "fish",
      "sql",
      "markdown",
      "rst",
      "text",
      "c",
      "cpp",
      "rust",
      "java",
      "kotlin",
      "ruby",
      "perl",
      "php",
    },
    callback = spaces(2),
  })

  -- Makefile: RICHIEDE tab (make fallisce con spazi)
  vim.api.nvim_create_autocmd("FileType", {
    group = G,
    pattern = { "make", "automake" },
    callback = function(ev)
      vim.bo[ev.buf].expandtab = false
      vim.bo[ev.buf].tabstop = 4
      vim.bo[ev.buf].shiftwidth = 4
    end,
  })

  -- Override globale post-sleuth: re-impone expandtab su ogni file
  -- letto. vim.schedule() assicura che giri DOPO gli autocmd di
  -- vim-sleuth (registrati più tardi perché il plugin si carica
  -- dopo set_options.lua), così sleuth continua a rilevare
  -- shiftwidth correttamente ma non può disabilitare expandtab.
  vim.api.nvim_create_autocmd("BufReadPost", {
    group = G,
    pattern = "*",
    callback = function(ev)
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(ev.buf) then
          return
        end
        local ft = vim.bo[ev.buf].filetype
        -- Eccezioni: formati che richiedono tab per definizione
        if ft ~= "make" and ft ~= "automake" and ft ~= "gitconfig" then
          vim.bo[ev.buf].expandtab = true
        end
      end)
    end,
  })
end

-- ── Ricerca ──────────────────────────────────────────────────
vim.opt.path:append("**")
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrapscan = true

-- ── Cursore / visualizzazione ────────────────────────────────
vim.opt.cursorcolumn = true
vim.opt.cursorline = true
vim.opt.scrolloff = 4
vim.opt.virtualedit = "block"
vim.opt.termguicolors = true

-- ── Numeri di riga: assoluto + relativo affiancati ───────────
-- Entrambe le opzioni attive: Neovim mostra il numero assoluto
-- sulla riga corrente e quello relativo sulle altre.
-- statuscol.nvim (programming.lua) affianca i due campi su
-- ogni riga contemporaneamente nella statuscolumn.
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes" -- larghezza fissa, evita il "jump"

-- ── Mouse / clipboard ────────────────────────────────────────
vim.opt.mouse = "a"
-- ── Clipboard: WSL / SSH+OSC52 / nativo ────────────────────
-- vim.g.clipboard = "osc52"
-- Sync clipboard between OS and Neovim.
vim.opt.clipboard = "unnamed,unnamedplus"
if os.getenv("DISPLAY") then
  local function paste()
    return {
      vim.fn.split(vim.fn.getreg(""), "\n"),
      vim.fn.getregtype(""),
    }
  end
  local osc52 = require("vim.ui.clipboard.osc52")
  vim.g.clipboard = {
    name = "osc52",
    copy = {
      ["+"] = osc52.copy("+"),
      ["*"] = osc52.copy("*"),
    },
    paste = {
      ["+"] = paste,
      ["*"] = paste,
    },
  }
else
  if os.getenv("WSL_DISTRO_NAME") then
    -- vim.g.clipboard = "osc52"
    vim.g.clipboard = {
      name = "WslClipboard",
      copy = {
        ["+"] = "clip.exe",
        ["*"] = "clip.exe",
      },
      paste = {
        ["+"] = 'powershell.exe -NoLogo -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
        ["*"] = 'powershell.exe -NoLogo -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      },
      cache_enabled = false,
    }
  end
end
-- unnamed,unnamedplus: sincronizza i registri + e * con il clipboard
vim.opt.clipboard = "unnamed,unnamedplus"

-- ── Editing ──────────────────────────────────────────────────
vim.opt.breakindent = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.nrformats = { "bin", "octal", "hex" }

-- ── Undo persistente ─────────────────────────────────────────
vim.opt.undofile = true
local undodir = vim.fn.stdpath("state") .. "/undo"
---@diagnostic disable-next-line: param-type-mismatch
vim.opt.undodir = undodir
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, "p")
end

-- ── Timing ───────────────────────────────────────────────────
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- ── Simboli di lista ─────────────────────────────────────────
vim.opt.list = true
vim.opt.listchars = {
  eol = "\xc2\xb6", -- U+00B6  ¶
  tab = "\xe2\x80\xb9\xc2\xb7\xe2\x80\xba", -- U+2039 U+00B7 U+203A  ‹·›
  trail = "\xc2\xb7", -- U+00B7  ·
  extends = "\xe2\x80\xba", -- U+203A  ›
  precedes = "\xe2\x80\xb9", -- U+2039  ‹
  nbsp = "\xe2\x80\xa2", -- U+2022  •
  conceal = "\xc3\x97", -- U+00D7  ×
}
vim.opt.showbreak = "\xe2\xae\x8e" -- U+2B8E  ⮎

-- ── fillchars ────────────────────────────────────────────────
-- Ogni campo deve essere esattamente 1 codepoint con
-- display-width = 1.  I glifi Nerd Font (PUA U+E000-F8FF) sono
-- scritti come escape esadecimali Lua (\xNN) in modo che
-- sopravvivano alla serializzazione JSON dei tool e vengano
-- espansi correttamente dal parser Lua a runtime.
vim.opt.fillchars = {
  fold = "\xc2\xb7", -- U+00B7  ·   MIDDLE DOT
  foldopen = "▾",
  foldclose = "▸",
  foldsep = "\xe2\x94\x82", -- U+2502  │   BOX DRAWINGS LIGHT VERTICAL
}

-- ── Folding ───────────────────────────────────────────────────
-- foldexpr usa la Lua API nativa di Neovim: disponibile prima
-- che nvim-treesitter sia caricato (vim.treesitter e' core).
-- nvim-ufo sovrascrivera' foldmethod/foldexpr quando attivo.
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldminlines = 5
vim.opt.foldenable = true
vim.opt.foldnestmax = 10

-- ── Spell ────────────────────────────────────────────────────
vim.opt.encoding = "utf-8"
vim.opt.spell = false
vim.opt.spelllang = { "en_us", "it", "eo" }
local spelldir = vim.fn.stdpath("data") .. "/site/spell"
if vim.fn.isdirectory(spelldir) == 0 then
  vim.fn.mkdir(spelldir, "p")
end

-- ── Bordo per finestre floating ──────────────────────────────
-- In 0.12+/0.13 il bordo di hover e signatureHelp NON si imposta
-- tramite vim.lsp.handlers.* (API in via di deprecazione) ne'
-- tramite vim.lsp.with() (gia' deprecata).
-- La forma idiomatica e' passare il bordo direttamente nei
-- keymap che chiamano vim.lsp.buf.hover() e .signature_help();
-- vedi lua/plugins/mason_lsp.lua.
-- Qui definiamo solo la costante usata da vim.diagnostic.config.
local _border = "single"

-- ── Diagnostics ──────────────────────────────────────────────
-- BREAKING CHANGE 0.12: i diagnostic signs non si configurano
-- piu' con vim.fn.sign_define(); passano per vim.diagnostic.config.
-- I glifi dei segni usano Nerd Font (PUA); scritti come \xNN.
vim.diagnostic.config({
  float = { border = _border },
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "\xef\x82\x9a ", -- nf-fa-times_circle
      [vim.diagnostic.severity.WARN] = "\xef\x80\xb1 ", -- nf-fa-warning
      [vim.diagnostic.severity.INFO] = "\xef\x82\x9c ", -- nf-fa-info_circle
      [vim.diagnostic.severity.HINT] = "\xee\x83\x96 ", -- nf-md-lightbulb
    },
  },
  underline = true,
  update_in_insert = true,
  virtual_text = true,
})
