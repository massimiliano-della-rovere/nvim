-- ============================================================
-- plugins/programming.lua  --  Neovim 0.12 / 0.13-compatible
-- ============================================================

local km = require("keymaps") -- prefissi centralizzati
return {

  -- ── Rilevamento automatico tab/shiftwidth ─────────────────
  "tpope/vim-sleuth",

  -- NOTA: numToStr/Comment.nvim rimosso (2026): gc/gcc sono nativi
  -- da Neovim 0.10 (rispettano 'commentstring' per filetype). Se in
  -- futuro serve commentstring "context-aware" per linguaggi
  -- embedded (es. JS dentro HTML), reintrodurre il plugin insieme a
  -- ts_context_commentstring; finché non serve, è peso morto.

  -- ── Evidenzia parola sotto cursore ────────────────────────
  {
    "RRethy/vim-illuminate",
    config = function()
      vim.api.nvim_set_hl(0, "IlluminatedWordText", { altfont = true, standout = true })
      vim.api.nvim_set_hl(0, "IlluminatedWordRead", { altfont = true, standout = true })
      vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { altfont = true, standout = true })
      require("illuminate").configure()
    end,
  },

  -- ── TODO / FIX / NOTE highlights ──────────────────────────
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local todo = require("todo-comments")
      todo.setup()
      vim.keymap.set("n", "]t", function()
        todo.jump_next()
      end, { desc = "TODO: next" })
      vim.keymap.set("n", "[t", function()
        todo.jump_prev()
      end, { desc = "TODO: prev" })
      vim.keymap.set("n", "]T", function()
        todo.jump_next({ keywords = { "ERROR", "WARNING" } })
      end, { desc = "TODO: next error/warn" })
      vim.keymap.set("n", "[T", function()
        todo.jump_prev({ keywords = { "ERROR", "WARNING" } })
      end, { desc = "TODO: prev error/warn" })
      vim.keymap.set("n", km.notes .. "l", "<CMD>TodoLocList<CR>", { desc = "Notes: loclist" })
      vim.keymap.set("n", km.notes .. "q", "<CMD>TodoQuickFix<CR>", { desc = "Notes: quickfix" })
      vim.keymap.set("n", km.notes .. "t", "<CMD>TodoTrouble<CR>", { desc = "Notes: trouble" })
      vim.keymap.set("n", km.notes .. "v", "<CMD>TodoTelescope<CR>", { desc = "Notes: telescope" })
    end,
  },

  -- ── TODO age: età dei commenti via git blame ──────────────
  -- ============================================================
  -- harukikuri/todoage.nvim
  -- ============================================================
  -- Mostra come virtual text inline l'età in giorni di ogni
  -- commento TODO/FIXME/HACK, ricavata da "git blame".
  -- Coesiste con todo-comments.nvim: todoage aggiunge SOLO
  -- l'annotazione dell'età (es. "42d"), senza toccare colori,
  -- quickfix o ricerca.
  --
  -- Requisiti: Neovim 0.10+ (vim.system), git in PATH,
  --            parser Treesitter per il linguaggio del buffer.
  --
  -- COMANDI:
  --   :Todoage          aggiorna il buffer corrente
  --   :TodoageEnable    riabilita e ri-annota
  --   :TodoageDisable   rimuove le annotazioni e sospende
  --   :TodoageToggle    abilita / disabilita
  --
  -- KEYMAP:
  --   <leader>nA        toggle on/off
  -- ============================================================
  {
    "harukikuri/todoage.nvim",
    event = { "BufReadPost", "BufWritePost" },
    config = function()
      require("todoage").setup({
        -- Lista parole chiave allineata a todo-comments.nvim.
        -- NOTA: setup() sostituisce la lista intera, non la fonde.
        keywords = {
          "TODO",
          "FIXME",
          "HACK",
          "BUG",
          "NOTE",
          "WARN",
          "WARNING",
          "PERF",
          "OPTIM",
          "PERFORMANCE",
          "OPTIMIZE",
        },

        -- Formato: riceve l'età in giorni, deve restituire una stringa.
        -- Qui usiamo una scala leggibile: giorni → settimane → mesi → anni.
        format = function(age_days)
          if age_days < 7 then
            return string.format(" (%dd)", age_days)
          elseif age_days < 30 then
            return string.format(" (%dw)", math.floor(age_days / 7))
          elseif age_days < 365 then
            return string.format(" (%dm)", math.floor(age_days / 30))
          else
            return string.format(" (%dy)", math.floor(age_days / 365))
          end
        end,
      })

      -- Highlight: fuori da setup() perché il README lo indica
      -- esplicitamente, e agganciati a ColorScheme per sopravvivere
      -- ai cambi di tema a runtime.
      local function set_hl()
        -- Giallo-ambra per le annotazioni committate
        vim.api.nvim_set_hl(0, "TodoageAge", { fg = "#d7af5f", italic = true })
        -- Grigio scuro per i TODO non ancora committati
        vim.api.nvim_set_hl(0, "TodoageUncommitted", { fg = "#5f5f5f", italic = true })
      end
      set_hl()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("TodoageHL", { clear = true }),
        callback = set_hl,
      })

      vim.keymap.set("n", km.notes .. "A", "<CMD>TodoageToggle<CR>", { desc = "TODOage: toggle" })
    end,
  },

  -- ── Evidenzia area attorno alle parentesi corrispondenti ──
  {
    "rareitems/hl_match_area.nvim",
    config = function()
      require("hl_match_area").setup({ highlight_in_insert_mode = true, delay = 100 })
      if not vim.startswith(vim.g.colors_name or "default", "kanagawa") then
        vim.api.nvim_set_hl(0, "MatchArea", { bg = "#4A2400" })
      else
        vim.api.nvim_set_hl(0, "MatchArea", { bg = "#303030" })
      end
    end,
  },

  -- ── Parentesi arcobaleno ──────────────────────────────────
  {
    "HiPhish/rainbow-delimiters.nvim",
    config = function()
      local rd = require("rainbow-delimiters")
      vim.g.rainbow_delimiters = {
        strategy = { [""] = rd.strategy["global"], vim = rd.strategy["local"] },
        query = { [""] = "rainbow-delimiters", lua = "rainbow-blocks" },
        priority = { [""] = 110, lua = 210 },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }
    end,
  },

  -- ── Guide di indentazione arcobaleno ─────────────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      local colors = {
        { "RainbowRed", "#E06C75" },
        { "RainbowYellow", "#E5C07B" },
        { "RainbowBlue", "#61AFEF" },
        { "RainbowOrange", "#D19A66" },
        { "RainbowGreen", "#98C379" },
        { "RainbowViolet", "#C678DD" },
        { "RainbowCyan", "#56B6C2" },
      }
      local hl_names = vim.tbl_map(function(c)
        return c[1]
      end, colors)
      local hooks = require("ibl.hooks")
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        for _, c in ipairs(colors) do
          vim.api.nvim_set_hl(0, c[1], { fg = c[2] })
        end
      end)
      vim.g.rainbow_delimiters = { highlight = hl_names }
      require("ibl").setup({ scope = { highlight = hl_names } })
      hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
    end,
  },

  -- ── Outline del codice (Aerial) ───────────────────────────
  {
    "stevearc/aerial.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    config = function()
      local aerial_inherited = require("aerial_inherited")

      require("aerial").setup({
        default_direction = "prefer_right",
        open_automatic = false,
        show_guides = true,
        filter_kind = false,
        autojump = true,
        highlight_on_hover = true,
        manager_folds = true,

        -- on_attach: chiamato quando aerial si attacca a un buffer.
        -- Notifica aerial_inherited del source bufnr PRIMA che l'aerial
        -- buffer venga creato, cosi' la correlazione FileType aerial
        -- puo' avvenire correttamente.
        on_attach = function(bufnr)
          aerial_inherited.on_attach(bufnr)
        end,
      })

      -- Attiva il modulo che mostra i metodi ereditati nell'aerial buffer
      aerial_inherited.setup()

      vim.keymap.set("n", km.lsp .. "d", "<CMD>AerialToggle<CR>", { desc = "Aerial: toggle" })
      vim.keymap.set("n", km.lsp .. "n", "<CMD>AerialNavToggle<CR>", { desc = "Aerial: nav" })
      -- <leader>ls → aerial symbols (corrente buffer)
      -- <leader>vs è riservato a telescope builtin.symbols (telescope.lua)
      vim.keymap.set("n", km.lsp .. "s", function()
        require("telescope").load_extension("aerial")
        require("telescope").extensions.aerial.aerial()
      end, { desc = "Aerial: document symbols" })
    end,
  },

  -- ── lazydev: API Neovim nel completamento Lua ─────────────
  -- ============================================================
  -- folke/lazydev.nvim  --  tipi Neovim per lua_ls
  -- ============================================================
  -- Inietta automaticamente il runtime di Neovim in lua_ls quando
  -- si apre un file Lua della config (init.lua, lua/**/*.lua).
  -- Sostituisce il vecchio approccio workspace.library manuale che
  -- caricava TUTTO il runtime e rallentava lo startup di lua_ls.
  --
  -- Risultato: vim.api.*, vim.fn.*, vim.lsp.* ecc. non vengono
  -- piu' sottolineati; completamento e hover funzionano su tutto
  -- il namespace vim.* senza warning "undefined field".
  -- ============================================================
  {
    "folke/lazydev.nvim",
    ft = "lua",
    dependencies = {
      -- Tipi completi per vim.uv (libuv / luv)
      { "Bilal2453/luvit-meta", lazy = true },
      -- Tipi per nvim-dap-ui (usati nella config dap)
      { "rcarriga/nvim-dap-ui" },
    },
    opts = {
      library = {
        -- Runtime Neovim: vim.api.*, vim.fn.*, vim.lsp.* ecc.
        { path = vim.env.VIMRUNTIME .. "/lua", words = { "vim%." } },
        -- tipi di vim.uv (libuv bindings)
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        -- lazy.nvim stesso (LazyPlugin, LazySpec, etc.)
        { path = "lazy.nvim" },
        -- nvim-dap-ui: tipi per dapui nelle config dap
        { path = "nvim-dap-ui", types = true },
      },
    },
  },

  -- ── Emmet abbreviations ───────────────────────────────────
  {
    "olrtg/nvim-emmet",
    config = function()
      vim.keymap.set({ "n", "v" }, km.emmet, require("nvim-emmet").wrap_with_abbreviation, { desc = "Emmet: wrap" })
    end,
  },

  -- ── Language injections (treesitter) ─────────────────────
  {
    "Dronakurl/injectme.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    lazy = true,
    cmd = { "InjectmeToggle", "InjectmeSave", "InjectmeInfo", "InjectmeLeave" },
  },

  -- ── Unison language support ───────────────────────────────
  {
    "unisonweb/unison",
    branch = "trunk",
    config = function(plugin)
      vim.opt.rtp:append(plugin.dir .. "/editor-support/vim")
      require("lazy.core.loader").packadd(plugin.dir .. "/editor-support/vim")
    end,
    init = function(plugin)
      require("lazy.core.loader").ftdetect(plugin.dir .. "/editor-support/vim")
    end,
  },

  -- ══════════════════════════════════════════════════════════
  -- STATUSCOLUMN: numero assoluto + relativo affiancati
  -- ══════════════════════════════════════════════════════════
  -- Layout (sx -> dx):  [ fold ][ absN  relN ][ signs ]
  --
  -- I segni OOP (↑ ↓ ↕) vengono inseriti da oop_signs.lua
  -- tramite nvim_buf_set_extmark (extmarks API, non sign_define).
  -- Non servono piu' vim.fn.sign_define() per i segni OOP:
  -- gli extmarks con sign_text/sign_hl_group si rendono
  -- automaticamente nel segmento %s di statuscol.
  -- ══════════════════════════════════════════════════════════
  {
    "luukvbaal/statuscol.nvim",
    dependencies = {
      "mfussenegger/nvim-dap",
      "lewis6991/gitsigns.nvim",
    },
    config = function()
      local statuscol = require("statuscol")
      local builtin = require("statuscol.builtin")

      statuscol.setup({
        relculright = true,
        segments = {
          -- fold marker
          { text = { "%C" }, click = "v:lua.ScFa" },

          -- numero assoluto (sempre visibile su ogni riga)
          {
            text = {
              function(args)
                return string.format("%4d", args.lnum)
              end,
              " ",
            },
            click = "v:lua.ScLa",
          },

          -- numero relativo (distanza dalla riga corrente)
          {
            text = {
              function(args)
                local rel = math.abs(vim.api.nvim_win_get_cursor(0)[1] - args.lnum)
                if rel == 0 then
                  return string.format("%-4d", args.lnum)
                end
                return string.format("%-4d", rel)
              end,
              " ",
            },
            condition = { true, builtin.not_empty },
            click = "v:lua.ScLa",
          },

          -- Colonna segni: git, dap breakpoint, OOP extmarks, diagnostics.
          -- OopSignClick: se la riga ha un segno OOP (↑ ↓ ↕) naviga
          -- alla/e definizione/i; altrimenti comportamento standard.
          { text = { "%s" }, click = "v:lua.OopSignClick" },
        },
      })

      -- Ricalcola i numeri relativi ad ogni movimento cursore
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = vim.api.nvim_create_augroup("StatuscolRefresh", { clear = true }),
        callback = function()
          vim.wo.statuscolumn = vim.wo.statuscolumn
        end,
      })
    end,
  },

  -- ============================================================
  -- MeanderingProgrammer/render-markdown.nvim
  -- ============================================================
  -- Renderizza i file Markdown direttamente nel buffer Neovim:
  -- intestazioni stilizzate, tabelle allineate, checkbox
  -- interattive, blocchi di codice con bordo e highlight.
  -- Attivo solo in normal mode (non in insert per non disturbare
  -- la scrittura). Richiede il parser Treesitter per markdown.
  --
  -- <leader>nm   toggle render on/off nel buffer corrente
  -- ============================================================
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "rmd", "org", "norg" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("render-markdown").setup({
        enabled = true,
        -- Renderizza solo in normal/command mode, non in insert
        render_modes = { "n", "c", "t" },
        max_file_size = 10.0, -- MB

        heading = {
          enabled = true,
          sign = true,
          position = "overlay",
          icons = {
            "\xe2\x96\x88 ", -- █ H1
            "\xe2\x96\x93 ", -- ▓ H2
            "\xe2\x96\x92 ", -- ▒ H3
            "\xe2\x96\x91 ", -- ░ H4
            "\xe2\x97 ", -- ◆ H5
            "\xe2\x97 ", -- ◇ H6
          },
          width = "full",
          left_pad = 0,
          right_pad = 0,
        },

        code = {
          enabled = true,
          sign = false,
          style = "full", -- blocco con bordi
          position = "left",
          border = "thin",
          language_pad = 1,
          width = "full",
          min_width = 40,
        },

        bullet = {
          enabled = true,
          icons = { "\xe2\x80\xa2", "\xe2\x97¦", "\xe2\x80\xa3", "\xe2\x80\xa2" },
          --          •                    ◦                   ‣                   •
        },

        checkbox = {
          enabled = true,
          position = "overlay",
          unchecked = { icon = "\xe2\x98\x90 " }, -- ☐
          checked = { icon = "\xe2\x9c\x94 " }, -- ✔
        },

        table = {
          enabled = true,
          style = "full",
          cell = "padded",
        },

        link = {
          enabled = true,
          hyperlink = "\xf0\x9f\x94\x97", -- 🔗
          image = "\xf0\x9f\x96\xbc \xef\xb8\x8f", -- 🖼 ️
        },

        sign = {
          enabled = false, -- disabilitato: troppo rumore con altri segni
        },

        win_options = {
          conceallevel = {
            default = vim.api.nvim_get_option_value("conceallevel", { scope = "local" }),
            rendered = 2,
          },
        },
      })

      vim.keymap.set("n", km.notes .. "m", "<CMD>RenderMarkdown toggle<CR>", { desc = "Markdown: toggle render" })
    end,
  },
}
