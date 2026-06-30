-- ============================================================
-- plugins/treesitter.lua  --  Neovim 0.12 / 0.13-compatible
-- ============================================================

local km = require("keymaps") -- prefissi centralizzati
return {

  -- ── nvim-treesitter core ──────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = {
          "vim",
          "regex",
          "lua",
          "bash",
          "markdown",
          "markdown_inline",
          "c",
          "css",
          "javascript",
          "python",
          "query",
          "sql",
          "typescript",
          "unison",
          "vimdoc",
        },
        auto_install = true,

        highlight = {
          enable = true,
          disable = function(_, buf)
            local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
            return ok and stats and stats.size > 100 * 1024
          end,
          additional_vim_regex_highlighting = false,
        },

        indent = { enable = true },

        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<CR>",
            node_incremental = "<CR>",
            scope_incremental = "<TAB>",
            node_decremental = "<BS>",
          },
        },

        -- ── textobjects ────────────────────────────────────
        -- Text object semantici basati sul parse tree.
        -- Si usano con d/y/c/v come qualsiasi text object Vim.
        -- La selezione lookahead cerca il nodo anche se il cursore
        -- è prima di esso nella stessa riga.
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              -- Funzioni e metodi
              ["af"] = { query = "@function.outer", desc = "outer function" },
              ["if"] = { query = "@function.inner", desc = "inner function" },
              -- Classi
              ["ac"] = { query = "@class.outer", desc = "outer class" },
              ["ic"] = { query = "@class.inner", desc = "inner class" },
              -- Parametri
              ["aa"] = { query = "@parameter.outer", desc = "outer parameter" },
              ["ia"] = { query = "@parameter.inner", desc = "inner parameter" },
              -- Loop
              ["al"] = { query = "@loop.outer", desc = "outer loop" },
              ["il"] = { query = "@loop.inner", desc = "inner loop" },
              -- Condizionali
              ["ai"] = { query = "@conditional.outer", desc = "outer if" },
              ["ii"] = { query = "@conditional.inner", desc = "inner if" },
              -- Blocchi
              ["ab"] = { query = "@block.outer", desc = "outer block" },
              ["ib"] = { query = "@block.inner", desc = "inner block" },
              -- Call
              ["aF"] = { query = "@call.outer", desc = "outer call" },
              ["iF"] = { query = "@call.inner", desc = "inner call" },
            },
            -- Mostra la selezione in selection_modes appropriata
            selection_modes = {
              ["@parameter.outer"] = "v",
              ["@function.outer"] = "V",
              ["@class.outer"] = "V",
            },
            include_surrounding_whitespace = false,
          },

          -- Swap argomenti con <M-,> e <M-.>
          swap = {
            enable = true,
            swap_next = { ["<M-.>"] = "@parameter.inner" },
            swap_previous = { ["<M-,>"] = "@parameter.inner" },
          },

          -- Move: salta al prossimo/precedente nodo sintattico.
          -- Usiamo lettere non usate da gitsigns ([c/]c) o unimpaired.
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]f"] = { query = "@function.outer", desc = "Next function" },
              ["]k"] = { query = "@class.outer", desc = "Next class" },
            },
            goto_next_end = {
              ["]F"] = { query = "@function.outer", desc = "Next function end" },
              ["]K"] = { query = "@class.outer", desc = "Next class end" },
            },
            goto_previous_start = {
              ["[f"] = { query = "@function.outer", desc = "Prev function" },
              ["[k"] = { query = "@class.outer", desc = "Prev class" },
            },
            goto_previous_end = {
              ["[F"] = { query = "@function.outer", desc = "Prev function end" },
              ["[K"] = { query = "@class.outer", desc = "Prev class end" },
            },
          },

          -- Lsp_interop: mostra preview del nodo in floating window
          lsp_interop = {
            enable = true,
            border = "single",
            peek_definition_code = {
              [km.lsp .. "p"] = "@function.outer",
              [km.lsp .. "P"] = "@class.outer",
            },
          },
        },
      })

      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    end,
  },

  -- ── nvim-treesitter-context ───────────────────────────────
  -- ============================================================
  -- Mostra in cima alla finestra il contesto corrente
  -- (nome della funzione, classe, loop) quando scorri lontano
  -- dalla definizione. Identico al comportamento di IntelliJ.
  --
  -- [C  →  salta al contesto corrente (utile per vedere la firma
  --         della funzione in cui sei, poi torna con <C-o>)
  -- ============================================================
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("treesitter-context").setup({
        enable = true,
        max_lines = 4, -- max righe di contesto mostrate
        min_window_height = 20, -- non mostra su finestre piccole
        line_numbers = true,
        multiline_threshold = 3, -- tronca contesti multi-riga lunghi
        trim_scope = "outer", -- se troppo lungo, tronca dall'esterno
        mode = "cursor",
        separator = "\xe2\x94\x80", -- ─ separatore visivo
        zindex = 20,
        on_attach = nil, -- callback opzionale
      })

      -- Highlight: rende il contesto leggermente distinto
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("TSContextHL", { clear = true }),
        callback = function()
          -- Copia il colore di CursorLine con fg più chiaro
          vim.api.nvim_set_hl(0, "TreesitterContext", { link = "CursorLine", default = false })
          vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", { link = "CursorLineNr", default = false })
          vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { link = "Comment", default = false })
        end,
      })

      -- [C: salta al contesto (uppercase per non confondere con ]c di gitsigns)
      vim.keymap.set("n", "[C", function()
        require("treesitter-context").go_to_context(vim.v.count1)
      end, { desc = "TSContext: jump to context" })
    end,
  },
}
