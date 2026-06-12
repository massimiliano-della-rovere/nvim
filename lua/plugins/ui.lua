-- ============================================================
-- plugins/ui.lua  –  Neovim 0.12
-- ============================================================

local km = require("keymaps")

return {
  -- ── Dressing: uso di telescope invece di vim.ui.select ──
  {
    "stevearc/dressing.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    event = "VeryLazy",
    opts = function()
      return {
        select = {
          enabled = true,
          -- Puoi forzare 'telescope', 'fzf_lua', 'snacks', o lasciarlo su 'builtin'
          backend = { "telescope", "fzf_lua", "builtin" },
          telescope = require("telescope.themes").get_cursor(), -- Rende la finestra compatta sotto il cursore
        },
      }
    end,
  },

  -- ── Marks visibili nella gutter ──────────────────────────
  {
    "chentoast/marks.nvim",
    config = function()
      require("marks").setup()
    end,
  },

  -- ── Which-key: guida ai keymap ────────────────────────────
  {
    "folke/which-key.nvim",
    dependencies = { "echasnovski/mini.icons" },
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    config = function()
      require("which-key").add({

        -- ── Gruppi radice ─────────────────────────────────
        { "<leader>", group = "VISUAL <leader>" },
        { km.ai, group = "CodeCompanion" },
        { km.ai .. "I", group = "inline assist" },
        { km.db, group = "db / buffer" },
        { km.db .. "s", group = "buffer sort" },
        { km.copilot, group = "CopilotChat" },
        { km.colorscheme, group = "colorscheme" },
        { km.colorscheme .. "c", group = "catppuccin" },
        { km.colorscheme .. "g", group = "gruvbox" },
        { km.colorscheme .. "k", group = "kanagawa" },
        { km.colorscheme .. "t", group = "tokyonight" },
        { km.debug, group = "debug / DAP" },
        { km.find, group = "find" },
        { km.flash, group = "flash" },
        { km.git, group = "git" },
        { km.fugitive, group = "fugitive" },
        { km.harpoon, group = "harpoon" },
        { km.docker, group = "docker" },
        { km.lsp, group = "LSP / code" },
        { km.lsp_hier, group = "OOP hierarchy" },
        { km.notes, group = "notes / TODO" },
        { km.oil, group = "oil" },
        { km.rename, group = "rename" },
        { km.remote, group = "remote SSH" },
        { km.surround, group = "surround" },
        { km.search, group = "search / replace" },
        { km.treesj, group = "treesj" },
        { km.test, group = "testing" },
        { km.view, group = "view" },
        { km.workspace, group = "workspace" },
        { km.trouble, group = "trouble" },

        -- ── Call hierarchy (telescope-hierarchy) ───────────
        { km.view .. "i", desc = "View: incoming calls (tree)" },
        { km.view .. "o", desc = "View: outgoing calls (tree)" },

        -- ── Testing: neotest ─────────────────────────────
        { km.test .. "t", desc = "Test: run nearest" },
        { km.test .. "T", desc = "Test: run file" },
        { km.test .. "a", desc = "Test: run all" },
        { km.test .. "l", desc = "Test: run last" },
        { km.test .. "s", desc = "Test: summary panel" },
        { km.test .. "o", desc = "Test: output" },
        { km.test .. "O", desc = "Test: output panel" },
        { km.test .. "d", desc = "Test: debug nearest" },
        { km.test .. "w", desc = "Test: watch file" },
        { km.test .. "x", desc = "Test: stop" },

        -- ── Harpoon ──────────────────────────────────────
        { km.harpoon .. "a", desc = "Harpoon: add file" },
        { km.harpoon .. "h", desc = "Harpoon: menu" },
        { km.harpoon .. "f", desc = "Harpoon: telescope picker" },
        { km.harpoon .. "[", desc = "Harpoon: prev file" },
        { km.harpoon .. "]", desc = "Harpoon: next file" },
        { "<M-1>", desc = "Harpoon: file 1" },
        { "<M-2>", desc = "Harpoon: file 2" },
        { "<M-3>", desc = "Harpoon: file 3" },
        { "<M-4>", desc = "Harpoon: file 4" },
        { "<M-5>", desc = "Harpoon: file 5" },
        { "<M-6>", desc = "Harpoon: file 6" },

        -- ── CodeCompanion (Claude) ─────────────────────
        -- { km.ai .. "c", desc = "Claude: chat toggle" },
        -- { km.ai .. "I", desc = "Claude: inline assist" },
        -- { km.ai .. "A", desc = "Claude: action palette" },
        -- { km.ai .. "B", desc = "Claude: add buffer to chat" },
        -- { km.ai .. "Ia", desc = "Claude: accept inline change" },
        -- { km.ai .. "Ir", desc = "Claude: reject inline change" },

        -- ── CopilotChat ────────────────────────────────
        -- { km.copilot .. "a", desc = "CopilotChat: open" },
        -- { km.copilot .. "s", desc = "CopilotChat: selection", mode = { "n", "v" } },
        -- { km.copilot .. "q", desc = "CopilotChat: quick ask" },
        -- { km.copilot .. "p", desc = "CopilotChat: prompt actions" },
        -- { km.copilot .. "x", desc = "CopilotChat: close" },
        -- { km.copilot .. "r", desc = "CopilotChat: reset" },

        -- ── Buffer (bufferline) ────────────────────────
        { km.db .. "p", desc = "Buffer: pick (jump)" },
        { km.db .. "c", desc = "Buffer: pick and close" },
        { km.db .. "P", desc = "Buffer: toggle pin" },
        { km.db .. "sd", desc = "Buffer: sort by directory" },
        { km.db .. "se", desc = "Buffer: sort by extension" },
        { km.db .. "st", desc = "Buffer: sort by tabs" },

        -- ── Note e markdown ────────────────────────────
        { km.notes .. "A", desc = "TODOage: toggle" },
        { km.notes .. "m", desc = "Markdown: toggle render" },

        -- ── LSP extra ─────────────────────────────────
        { km.lsp .. "F", desc = "Format: conform (async)" },
        { km.lsp .. "f", desc = "Format: toggle format-on-save" },
        { km.lsp .. "l", desc = "Lint: run on buffer" },
        { km.lsp .. "p", desc = "LSP: peek function def" },
        { km.lsp .. "P", desc = "LSP: peek class def" },
        { km.lsp_hier .. "s", desc = "OOP: list supertypes" },
        { km.lsp_hier .. "b", desc = "OOP: list subtypes" },
        { km.lsp_hier .. "S", desc = "OOP: jump supertype" },
        { km.lsp_hier .. "B", desc = "OOP: jump subtype" },

        -- ── Keymaps non-leader (nuove funzionalita) ───
        -- Flash
        { "s", desc = "Flash: jump", mode = { "n", "x", "o" } },
        { "S", desc = "Flash: treesitter select", mode = { "n", "x", "o" } },
        { "r", desc = "Flash: remote (operator)", mode = { "o" } },
        { "R", desc = "Flash: treesitter search", mode = { "o", "x" } },
        -- Treesitter context
        { "[C", desc = "TSContext: jump to context" },
        -- OOP signs navigation
        { "gO", desc = "OOP: navigate to related class" },
        -- Treesitter textobjects swap
        { "<M-,>", desc = "TS: swap prev parameter", mode = { "n" } },
        { "<M-.>", desc = "TS: swap next parameter", mode = { "n" } },
        -- Fast wrap (autopairs)
        { "<M-e>", desc = "Autopairs: fast wrap", mode = { "i" } },

        { "<leader>__", hidden = true },
      })
    end,
  },

  -- ── Ridimensione finestre animata ─────────────────────────
  {
    "anuvyklack/windows.nvim",
    dependencies = { "anuvyklack/middleclass", "anuvyklack/animation.nvim" },
    config = function()
      vim.opt.winwidth = 10
      vim.opt.winminwidth = 10
      vim.opt.equalalways = false
      require("windows").setup()
      vim.keymap.set("n", "<C-w>z", ":WindowsMaximize<CR>", { desc = "Window: maximize" })
      vim.keymap.set("n", "<C-w>_", ":WindowsMaximizeVertically<CR>", { desc = "Window: max vertical" })
      vim.keymap.set("n", "<C-w>|", ":WindowsMaximizeHorizontally<CR>", { desc = "Window: max horizontal" })
      vim.keymap.set("n", "<C-w>=", ":WindowsEqualize<CR>", { desc = "Window: equalize" })
    end,
  },

  -- ── Noice: UI per messaggi, cmdline e popupmenu ───────────
  {
    "folke/noice.nvim",
    config = function()
      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = false,
        },
      })
      require("telescope").load_extension("noice")
    end,
  },

  -- ============================================================
  -- akinsho/bufferline.nvim  --  buffer/tab bar
  -- ============================================================
  -- Sostituisce la visualizzazione buffer nella tabline di lualine
  -- (disabilitata in lualine.lua) con una barra dedicata che mostra:
  --   • buffer aperti con icona e numero
  --   • indicatori LSP (errori/warning per buffer)
  --   • stato git (modified)
  --   • tab groups separati dai buffer
  --
  -- KEYMAPS  (<leader>b):
  --   <leader>bp   buffer pick (salta con 1 lettera)
  --   <leader>bc   chiudi buffer corrente
  --   <leader>bP   fissa/de-fissa buffer (pin)
  --   <leader>bsd  ordina per directory
  --   <leader>bse  ordina per estensione
  --   <leader>bst  ordina per ultima modifica
  -- ============================================================
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local bufferline = require("bufferline")

      bufferline.setup({
        options = {
          mode = "buffers",
          style_preset = bufferline.style_preset.default,
          themable = true,
          numbers = "ordinal", -- mostra il numero per <M-N>

          -- Chiudi buffer con bdelete (close-buffers.vim già installato)
          close_command = "bdelete! %d",
          right_mouse_command = "bdelete! %d",
          left_mouse_command = "buffer %d",

          indicator = { icon = "\xe2\x96\x8e", style = "icon" }, -- ▎
          buffer_close_icon = "\xe2\x9c\x95", -- ✕
          modified_icon = "\xe2\x97\x8f", -- ●
          close_icon = "\xef\x80\x91", --
          left_trunc_marker = "\xef\x81\x84", --
          right_trunc_marker = "\xef\x81\x85", --

          max_name_length = 30,
          max_prefix_length = 15,
          truncate_names = true,
          tab_size = 18,

          -- Diagnostics LSP inline per buffer
          diagnostics = "nvim_lsp",
          diagnostics_update_in_insert = false,
          diagnostics_indicator = function(count, level)
            local icons = {
              error = "\xef\x82\x9a ", --
              warning = "\xef\x80\xb1 ", --
            }
            return (icons[level] or "") .. count
          end,

          -- Integrazione con gitsigns per mostrare stato git
          custom_filter = function(buf_number)
            -- Nasconde i buffer di servizio dalla barra
            local ft = vim.bo[buf_number].filetype
            local excluded = {
              "qf",
              "help",
              "nofile",
              "aerial",
              "neo-tree",
              "alpha",
              "lazy",
              "mason",
              "dap-repl",
              "dapui_console",
              "dapui_watches",
              "dapui_stacks",
              "dapui_breakpoints",
              "dapui_scopes",
            }
            for _, t in ipairs(excluded) do
              if ft == t then
                return false
              end
            end
            return true
          end,

          -- Mostra anche i tab nel bufferline (separati)
          show_buffer_close_icons = true,
          show_close_icon = false,
          show_tab_indicators = true,
          show_duplicate_prefix = true,

          separator_style = "thin",
          enforce_regular_tabs = false,
          always_show_bufferline = false, -- nasconde se un solo buffer
          hover = {
            enabled = true,
            delay = 150,
            reveal = { "close" },
          },

          -- Offset per neo-tree e aerial
          offsets = {
            {
              filetype = "neo-tree",
              text = "File Explorer",
              highlight = "Directory",
              separator = true,
            },
            {
              filetype = "aerial",
              text = "Outline",
              highlight = "Directory",
              separator = true,
            },
          },
        },
      })

      -- Keymaps
      vim.keymap.set("n", km.db .. "p", "<CMD>BufferLinePick<CR>", { desc = "Buffer: pick (jump)" })
      vim.keymap.set("n", km.db .. "c", "<CMD>BufferLinePickClose<CR>", { desc = "Buffer: pick and close" })
      vim.keymap.set("n", km.db .. "P", "<CMD>BufferLineTogglePin<CR>", { desc = "Buffer: toggle pin" })
      vim.keymap.set("n", km.db .. "sd", "<CMD>BufferLineSortByDirectory<CR>", { desc = "Buffer: sort by directory" })
      vim.keymap.set("n", km.db .. "se", "<CMD>BufferLineSortByExtension<CR>", { desc = "Buffer: sort by extension" })
      vim.keymap.set("n", km.db .. "st", "<CMD>BufferLineSortByTabs<CR>", { desc = "Buffer: sort by tabs" })

      -- I tasti <M-h>/<M-l> già in set_keymaps.lua navigano tra buffer;
      -- usiamo anche <S-h>/<S-l> come alternativa standard di bufferline
      vim.keymap.set("n", "<S-h>", "<CMD>BufferLineCyclePrev<CR>", { desc = "Buffer: prev" })
      vim.keymap.set("n", "<S-l>", "<CMD>BufferLineCycleNext<CR>", { desc = "Buffer: next" })
    end,
  },
}
