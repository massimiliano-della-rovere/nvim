local km = require("keymaps") -- prefissi centralizzati
return {

  -- git integration
  -- https://github.com/tpope/vim-fugitive
  "tpope/vim-fugitive",

  -- git :GBrowse
  -- https://github.com/tpope/vim-rhubarb
  "tpope/vim-rhubarb",

  -- git operation symbols on the symbol bar
  -- https://github.com/airblade/vim-gitgutter
  -- "airblade/vim-gitgutter",

  -- blame shown at the end of the line
  -- https://github.com/f-person/git-blame.nvim
  {
    "f-person/git-blame.nvim",
    event = "VeryLazy",
    config = function()
      require("highlight_git_blame")

      -- change the language of date_format
      -- require("lua-timeago").set_language(require("lua-timeago/languages/en"))

      require("gitblame").setup({
        enabled = true,
        date_format = "%Y-%m-%d %a %H:%M:%S",
        message_template = "   <author> 󰔠 <date> 󰈚 <summary>  <sha>",
        message_when_not_committed = "  Not Committed Yet",
        highlight_group = "GitBlameInline",
        set_extmark_options = {},
        display_virtual_text = true,
        ignored_filetypes = {},
        delay = 0,
        virtual_text_column = nil,
        -- open GitBlameOpenFileURL and GitBlameCopyFileURL at the latest blame commit
        -- (in other words, the commit marked by the blame)
        use_blame_commit_file_urls = true,
      })
    end,
  },

  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    -- https://github.com/lewis6991/gitsigns.nvim
    "lewis6991/gitsigns.nvim",
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = "+" },
        change = { text = "❙" }, -- ❚" }, -- │" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        vim.keymap.set({ "n", "v" }, "]c", function()
          if vim.wo.diff then
            return "]c"
          end
          vim.schedule(gs.next_hunk)
          return "<Ignore>"
        end, { expr = true, buffer = bufnr, desc = "Git: To next Change" })
        vim.keymap.set({ "n", "v" }, "[c", function()
          if vim.wo.diff then
            return "[c"
          end
          vim.schedule(gs.prev_hunk)
          return "<Ignore>"
        end, { expr = true, buffer = bufnr, desc = "Git: To prev Change" })

        -- Actions
        -- visual mode
        map("v", km.fugitive .. "s", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "GIT: Stage hunk" })
        map("v", km.fugitive .. "r", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "GIT: Reset hunk" })
        -- normal mode
        map("n", km.fugitive .. "s", gs.stage_hunk, { desc = "Git: stage hunk" })
        map("n", km.fugitive .. "r", gs.reset_hunk, { desc = "Git: reset hunk" })
        map("n", km.fugitive .. "S", gs.stage_buffer, { desc = "Git: Stage buffer" })
        map("n", km.fugitive .. "u", gs.undo_stage_hunk, { desc = "Git: Undo stage hunk" })
        map("n", km.fugitive .. "R", gs.reset_buffer, { desc = "Git: Reset buffer" })
        map("n", km.fugitive .. "p", gs.preview_hunk, { desc = "Git: Preview hunk" })
        map("n", km.fugitive .. "b", function()
          gs.blame_line({ full = false })
        end, { desc = "Git: blame line" })
        map("n", km.fugitive .. "d", gs.diffthis, { desc = "Git: Diff against index" })
        map("n", km.fugitive .. "D", function()
          gs.diffthis("~")
        end, { desc = "Git: Diff against last commit" })

        -- Toggles
        map("n", km.fugitive .. "B", gs.toggle_current_line_blame, { desc = "Git: Toggle blame" })
        map("n", km.fugitive .. "X", gs.toggle_deleted, { desc = "GIT: Toggle show deleted" })

        -- Text object
        map({ "o", "x" }, km.fugitive .. "h", ":<C-U>Gitsigns select_hunk<CR>", { desc = "GIT: Select hunk" })
      end,
    },
  },

  -- ============================================================
  -- petertriho/nvim-scrollbar  --  Change Overview Ruler
  -- ============================================================
  -- Barra verticale sul bordo destro della finestra che mostra
  -- la posizione delle modifiche Git su TUTTO il file (non solo
  -- le righe visibili), esattamente come il "Change Overview Ruler"
  -- di IntelliJ IDEA / PyCharm.
  --
  -- Legenda colori sulla barra:
  --   │  verde   righe aggiunte        (GitSignsAdd)
  --   │  giallo  righe modificate      (GitSignsChange)
  --   ▾  rosso   righe eliminate       (GitSignsDelete)
  --   ─  colori diagnostici            (Error / Warn / Info / Hint)
  --   █  grigio  viewport corrente     (thumb)
  --
  -- La barra sparisce automaticamente se l'intero file e' visibile
  -- sullo schermo (hide_if_all_visible = true) e viene esclusa
  -- dai buffer di servizio (aerial, neo-tree, oil, alpha, dap ...).
  --
  -- Dati letti da: lewis6991/gitsigns.nvim (gia' nel config)
  -- tramite il provider nativo providers.gitsigns = true (v2).
  -- ============================================================
  {
    "petertriho/nvim-scrollbar",
    -- TODO: rimuovere branch dopo il 2026-11-16
    --       (v2 sostituisce main; il branch "refactor/v2" viene
    --       eliminato e il tag "v2.0.0" sara' disponibile)
    branch = "refactor/v2",
    dependencies = { "lewis6991/gitsigns.nvim" },
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("scrollbar").setup({

        -- ── Top-level (v2 accetta solo queste chiavi al top-level):
        --    set_highlights, exclude, providers, marks, scrollbar, minimap
        set_highlights = true,

        -- ── Esclusioni (v1: excluded_buftypes / excluded_filetypes)
        --    Lista → sostituisce i default; tabella {nome=true} → aggiunge.
        exclude = {
          buftypes = {
            "terminal",
            "nofile",
            "quickfix",
            "prompt",
          },
          filetypes = {
            "aerial", -- outline simboli
            "alpha", -- dashboard
            "neo-tree", -- file browser
            "oil", -- file browser
            "TelescopePrompt",
            "noice",
            "notify",
            "lazy",
            "mason",
            "help",
            "DiffviewFiles",
            "dap-repl",
            "dapui_watches",
            "dapui_console",
            "dapui_stacks",
            "dapui_breakpoints",
            "dapui_scopes",
            "toggleterm",
          },
        },

        -- ── Provider (v1: handlers)
        --    gitsigns: non richiede piu' require("scrollbar.handlers.gitsigns").setup()
        --    handle:   rimosso come provider; il thumb e' sempre attivo nel layout
        --    search:   ora nativo (legge / e ?), non richiede nvim-hlslens
        providers = {
          cursor = true,
          diagnostic = true, -- posizioni diagnostics LSP
          gitsigns = true, -- hunks Git su tutto il file
          search = false, -- disabilitato: non usiamo la ricerca sulla barra
          ale = false,
        },

        -- ── Marks: formato invariato tra v1 e v2
        --    (text, priority, highlight-come-stringa restano uguali)
        marks = {
          Cursor = {
            text = "\xe2\x94\x80", -- U+2500 ─
            priority = 0,
            highlight = "Normal",
          },
          Search = {
            text = { "\xe2\x94\x80", "\xe2\x95\x90" }, -- ─  ═
            priority = 1,
            highlight = "Search",
          },
          Error = {
            text = { "\xe2\x94\x80", "\xe2\x95\x90" },
            priority = 2,
            highlight = "DiagnosticVirtualTextError",
          },
          Warn = {
            text = { "\xe2\x94\x80", "\xe2\x95\x90" },
            priority = 3,
            highlight = "DiagnosticVirtualTextWarn",
          },
          Info = {
            text = { "\xe2\x94\x80", "\xe2\x95\x90" },
            priority = 4,
            highlight = "DiagnosticVirtualTextInfo",
          },
          Hint = {
            text = { "\xe2\x94\x80", "\xe2\x95\x90" },
            priority = 5,
            highlight = "DiagnosticVirtualTextHint",
          },
          Misc = {
            text = { "\xe2\x94\x80", "\xe2\x95\x90" },
            priority = 6,
            highlight = "Normal",
          },
          -- Git: usa le stesse highlight di gitsigns per coerenza cromatica
          GitAdd = {
            text = "\xe2\x94\x82", -- U+2502 │  riga aggiunta
            priority = 7,
            highlight = "GitSignsAdd",
          },
          GitChange = {
            text = "\xe2\x94\x82", -- U+2502 │  riga modificata
            priority = 7,
            highlight = "GitSignsChange",
          },
          GitDelete = {
            text = "\xe2\x96\xbe", -- U+25BE ▾  riga eliminata
            priority = 7,
            highlight = "GitSignsDelete",
          },
        },

        -- ── Blocco scrollbar
        --    Tutte le opzioni che in v1 erano al top-level o in "handle"
        --    ora vivono qui, tranne set_highlights e marks.
        scrollbar = {
          -- v1: show = true (implicito: lo scrollbar e' visibile)
          -- v1: show_in_active_only = false → visibility = "all" (default v2)
          -- v1: max_lines = false → max_lines = false
          max_lines = false,
          -- v1: hide_if_all_visible = true
          hide_if_all_visible = true,
          -- v1: throttle_ms = 100  (default v2: 16 ms)
          throttle_ms = 100,
          -- v1: folds = 1000 → unit = "screenline"
          --     "screenline" considera fold chiusi e wrapped lines;
          --     "line" (default v2) non li considera.
          unit = "screenline",

          -- v1: handle → thumb
          --     handle.highlight "CursorColumn" → thumb.highlight
          --     (default v2 e' "PmenuThumb"; manteniamo il vecchio)
          thumb = {
            text = " ",
            blend = 30, -- leggermente semitrasparente
            highlight = "CursorColumn",
            hide_if_all_visible = true,
          },

          -- v1: autocmd.render → scrollbar.events
          --     autocmd.clear rimosso in v2 (usare visibility = "active"
          --     se si vuole nascondere la barra nelle finestre inattive)
          events = {
            "BufWinEnter",
            "TabEnter",
            "TermEnter",
            "WinEnter",
            "CmdwinLeave",
            "TextChanged",
            "VimResized",
            "WinScrolled",
          },
        },
      })
      -- require("scrollbar.handlers.gitsigns").setup() RIMOSSO:
      -- in v2 gitsigns e' un provider nativo (providers.gitsigns = true sopra).
    end,
  },

  {
    -- lazygit integration
    -- https://github.com/kdheepak/lazygit.nvim
    "kdheepak/lazygit.nvim",
    lazy = true,
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    -- optional for floating window border decoration
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
      { km.git .. "l", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },
}
