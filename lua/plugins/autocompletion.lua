-- ============================================================
-- plugins/autocompletion_copilot_cmp.lua  --  Neovim 0.12
-- Versione ALTERNATIVA: Copilot integrato nel menu nvim-cmp
-- ============================================================
-- Copilot appare nel menu cmp come sorgente "copilot" insieme
-- a LSP, snippet ecc. I suggerimenti si accettano con Tab/CR/C-y
-- senza tasti separati. Nessun ghost text (suggestion.enabled=false).
--
-- Per attivare questa versione: rinominare questo file in
-- autocompletion.lua (e mettere l'altro in .bak) poi riavviare.
--
-- Richiede: zbirenbaum/copilot.lua + zbirenbaum/copilot-cmp
-- Prima autenticazione: :Copilot auth  (dopo il primo InsertEnter)
-- ============================================================

local km = require("keymaps") -- prefissi centralizzati

local has_non_whitespace_before_cursor = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  if col == 0 then
    return false
  end

  local text = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
  return text:sub(1, col):find("%S") ~= nil
end

return {

  -- ============================================================
  -- nvim-cmp con sorgente Copilot integrata
  -- ============================================================
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "neovim/nvim-lspconfig",
      "andersevenrud/cmp-tmux",
      "David-Kunz/cmp-npm",
      "davidsierradz/cmp-conventionalcommits",
      "dmitmel/cmp-cmdline-history",
      "dmitmel/cmp-digraphs",
      "FelipeLema/cmp-async-path",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-calc",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-emoji",
      "hrsh7th/cmp-omni",
      "hrsh7th/cmp-nvim-lsp",
      -- Copilot come sorgente cmp (richiede zbirenbaum/copilot.lua)
      "zbirenbaum/copilot-cmp",
      "hrsh7th/cmp-nvim-lsp-document-symbol",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "kdheepak/cmp-latex-symbols",
      "lukas-reineke/cmp-rg",
      "petertriho/cmp-git",
      "rafamadriz/friendly-snippets",
      "rcarriga/cmp-dap",
      "saadparwaiz1/cmp_luasnip",
      "SergioRibera/cmp-dotenv",
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
      },
      "onsails/lspkind.nvim",
    },
    config = function()
      local cmp = require("cmp")
      local lspkind = require("lspkind")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()
      luasnip.config.setup({})

      cmp.setup({
        -- ghost_text disabilitato: i suggerimenti Copilot appaiono
        -- gia' nel menu; il ghost text di cmp e quello di copilot.lua
        -- si sovrapporrebbero.
        experimental = { ghost_text = false },
        preselect = cmp.PreselectMode.Item,
        enabled = function()
          return (
            vim.api.nvim_get_option_value("buftype", { buf = 0 }) ~= "prompt" and has_non_whitespace_before_cursor()
          ) or require("cmp_dap").is_dap_buffer()
        end,

        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = lspkind.cmp_format({
            mode = "symbol_text",
            menu = {
              async_path = "[Filesystem]",
              buffer = "[Buffer]",
              calc = "[Calc]",
              cmdline = "[CMD]",
              -- digraphs = "[Digraphs]",
              dap = "[DAP]",
              git = "[Git]",
              nvim_lsp = "[LSP]",
              latex_symbols = "[LaTeX]",
              lazydev = "[LazyDev]",
              luasnip = "[Snippet]",
              ["vim-dadbod-completion"] = "[DB]",
              nvim_lua = "[LUA]",
              orgmode = "[Org]",
              rg = "[Rg]",
              tags = "[Tag]",
              tmux = "[TMux]",
              copilot = "[Copilot]",
            },
          }),
        },

        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        -- completion = { completeopt = "menu,menuone" },
        completion = {
          -- autocomplete = false,
          autocomplete = { cmp.TriggerEvent.TextChanged },
          keyword_length = 1,
          keyword_pattern = [[\%(-\?\w\+\|\w\+\%(-\w*\)\?\)]],
          completeopt = "menu,menuone,noinsert,noselect",
        },
        window = {
          completion = {
            border = {
              "\xe2\x95\xad",
              "\xe2\x94\x80",
              "\xe2\x95\xae",
              "\xe2\x94\x82",
              "\xe2\x95\xaf",
              "\xe2\x94\x80",
              "\xe2\x95\xb0",
              "\xe2\x94\x82",
            },
          },
          documentation = {
            border = {
              "\xe2\x95\xad",
              "\xe2\x94\x80",
              "\xe2\x95\xae",
              "\xe2\x94\x82",
              "\xe2\x95\xaf",
              "\xe2\x94\x80",
              "\xe2\x95\xb0",
              "\xe2\x94\x82",
            },
          },
        },

        mapping = cmp.mapping.preset.insert({
          ["<C-Space"] = cmp.mapping.complete(),
          ["<PgUp>"] = cmp.mapping.scroll_docs(-4),
          ["<C-u>"] = cmp.mapping.scroll_docs(-4),
          ["<PgDown>"] = cmp.mapping.scroll_docs(4),
          ["<C-d>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete({}),
          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = false,
          }),
          ["<Esc>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.abort()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<C-y>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
          }),
          ["<C-n>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
            elseif luasnip.expandable() then
              luasnip.expand()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-p>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true })
            elseif luasnip.expandable() then
              luasnip.expand()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-l>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              return cmp.complete_common_string()
            end
            fallback()
          end, { "i", "s" }),
        }),

        -- ── Sorgenti: Copilot in cima con priorita' massima ──
        -- group_index = 1: appare nello stesso gruppo di LSP e
        -- snippet, non in un gruppo separato/fallback.
        sources = cmp.config.sources({
          { name = "copilot", group_index = 1, priority = 1100 },
          { name = "nvim_lsp", group_index = 1, priority = 1000 },
          { name = "luasnip", group_index = 1, priority = 900 },
          { name = "buffer" },
          { name = "tags", keyword_length = 2 },
          { name = "rg", keyword_length = 3 },
          { name = "async_path" },
          { name = "orgmode" },
          { name = "calc" },
          -- { name = "digraphs" },  -- disabilitato: interferisce con i tasti di navigazione
          { name = "dap" },
          { name = "cmdline" },
          { name = "nvim_lsp_signature_help" },
          { name = "latex_symbols" },
          { name = "lazydev" },
        }),
      })

      cmp.setup.filetype("gitcommit", {
        sources = cmp.config.sources({ { name = "git" } }, { { name = "buffer" } }),
      })
      cmp.setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
        sources = { { name = "dap" } },
      })

      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline({
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true })
            else
              fallback()
            end
          end, { "c" }),
          ["<C-y>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }),
          ["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
          ["<C-n>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
            else
              fallback()
            end
          end, { "c" }),
          ["<C-p>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
            else
              fallback()
            end
          end, { "c" }),
          ["<Down>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
            else
              fallback()
            end
          end, { "c" }),
          ["<Up>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
            else
              fallback()
            end
          end, { "c" }),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<C-l>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              return cmp.complete_common_string()
            end
            fallback()
          end, { "c" }),
        }),
        sources = { { name = "buffer" } },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline({
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true })
            else
              fallback()
            end
          end, { "c" }),
          ["<C-y>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }),
          ["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
          ["<C-n>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
            else
              fallback()
            end
          end, { "c" }),
          ["<C-p>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
            else
              fallback()
            end
          end, { "c" }),
          ["<Down>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
            else
              fallback()
            end
          end, { "c" }),
          ["<Up>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
            else
              fallback()
            end
          end, { "c" }),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<C-l>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              return cmp.complete_common_string()
            end
            fallback()
          end, { "c" }),
        }),
        sources = cmp.config.sources({ { name = "async_path", max_item_count = 20 } }, { { name = "cmdline" } }),
      })

      vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { bg = "NONE", strikethrough = true, fg = "#808080" })
      vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { bg = "NONE", fg = "#569CD6" })
      vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { link = "CmpItemAbbrMatch" })
      vim.api.nvim_set_hl(0, "CmpItemKindVariable", { bg = "NONE", fg = "#9CDCFE" })
      vim.api.nvim_set_hl(0, "CmpItemKindInterface", { link = "CmpItemKindVariable" })
      vim.api.nvim_set_hl(0, "CmpItemKindText", { link = "CmpItemKindVariable" })
      vim.api.nvim_set_hl(0, "CmpItemKindFunction", { bg = "NONE", fg = "#C586C0" })
      vim.api.nvim_set_hl(0, "CmpItemKindMethod", { link = "CmpItemKindFunction" })
      vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { bg = "NONE", fg = "#D4D4D4" })
      vim.api.nvim_set_hl(0, "CmpItemKindProperty", { link = "CmpItemKindKeyword" })
      vim.api.nvim_set_hl(0, "CmpItemKindUnit", { link = "CmpItemKindKeyword" })
    end,
  },

  -- ============================================================
  -- zbirenbaum/copilot.lua  --  backend Lua puro
  -- ============================================================
  -- Sostituisce github/copilot.vim. Parla con lo stesso Language
  -- Server GitHub Copilot tramite la stessa autenticazione OAuth.
  -- suggestion e panel sono disabilitati: i suggerimenti passano
  -- per il menu cmp tramite copilot-cmp.
  --
  -- COMANDI RUNTIME:
  --   :Copilot auth      avvia il flusso OAuth (prima volta)
  --   :Copilot status    verifica connessione e account
  --   :Copilot enable    riabilita dopo disable
  --   :Copilot disable   disabilita globalmente
  --   :Copilot detach    stacca dal buffer corrente
  --   :Copilot panel     suggerimenti interi in finestra separata
  -- ============================================================
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        -- suggestion/panel disabilitati: i suggerimenti
        -- appaiono nel menu cmp (via copilot-cmp).
        suggestion = { enabled = false },
        panel = { enabled = false },

        -- NES: Next Edit Suggestions (abilitato anche in
        -- questa versione; i suggerimenti NES appaiono
        -- comunque come ghost text separato dal menu cmp).
        server_opts_overrides = {
          settings = {
            advanced = {
              nextEditSuggestions = { enabled = true },
            },
          },
        },
        filetypes = {
          python = true,
          lua = true,
          typescript = true,
          javascript = true,
          TelescopePrompt = false,
          ["dap-repl"] = false,
          gitcommit = false,
          gitrebase = false,
          help = false,
          text = false,
        },
      })
    end,
  },

  -- ============================================================
  -- zbirenbaum/copilot-cmp  --  adattatore nvim-cmp
  -- ============================================================
  -- Espone copilot.lua come sorgente nvim-cmp con nome "copilot".
  -- fix_pairs corregge la gestione delle parentesi quando si
  -- accetta un suggerimento Copilot dal menu.
  -- ============================================================
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "zbirenbaum/copilot.lua" },
    config = function()
      require("copilot_cmp").setup({ fix_pairs = true })
    end,
  },

  -- ============================================================
  -- CopilotC-Nvim/CopilotChat.nvim  --  AI chat in Neovim
  -- ============================================================
  -- Chat con GitHub Copilot direttamente in Neovim, con contesto
  -- del buffer/selezione corrente, diagnostics LSP e storia.
  --
  -- KEYMAPS  (<leader>a):
  --   <leader>aa   apri chat (buffer completo come contesto)
  --   <leader>as   chat con selezione visuale
  --   <leader>aq   domanda rapida (vim.ui.input)
  --   <leader>ap   prompt actions (via Telescope)
  --   <leader>ax   chiudi chat
  --   <leader>ar   reset chat
  -- ============================================================
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    build = "make tiktoken",
    dependencies = {
      "zbirenbaum/copilot.lua",
      "nvim-lua/plenary.nvim",
    },
    event = "VeryLazy",
    opts = {
      -- https://github.com/CopilotC-Nvim/CopilotChat.nvim/blob/main/lua/CopilotChat/config.lua
      debug = false,
      -- models:
      -- * claude-haiku-4.5
      -- * gpt-5-mini* oswe-vscode-prime
      model = "auto",
      temperature = 0.1,
      trusted_tools = nil,
      -- system_prompt = require("CopilotChat.prompts").COPILOT_INSTRUCTIONS,

      headers = {
        user = "👤 You",
        assistant = "🤖 Copilot",
        tool = "🔧 Tool",
      },

      window = {
        layout = "vertical",
        width = 0.40,
        height = 0.50,
        border = "rounded",
        title = " 🤖 Copilot Chat 🤖 ",
        zindex = 50,
      },

      -- mappings = {
      --   complete = { insert = "<Tab>" },
      --   close = { normal = "q", insert = "<C-c>" },
      --   reset = { normal = "<M-r>", insert = "<M-r>" },
      --   submit_prompt = { normal = "<CR>", insert = "<M-CR>" },
      --   accept_diff = { normal = "<M-a>", insert = "<M-a>" },
      --   show_diff = { normal = "<M-d>" },
      --   show_system_prompt = { normal = "<M-s>" },
      --   show_user_selection = { normal = "<M-u>" },
      -- },

      -- Sorgenti di contesto predefinite
      context = "buffer", -- invia il buffer corrente come contesto
      history_path = vim.fn.stdpath("data") .. "/copilot_chat_history.json",
      auto_follow_cursor = true,
      auto_fold = true,
      auto_insert_mode = true,
      insert_at_end = true,
      clear_chat_on_new_prompt = false,
      highlight_selection = true,
      separator = "━━",
    },
    keys = {
      { km.copilot .. "c", ":CopilotChat<CR>", mode = { "n", "v" }, desc = "CopilotChat chat" },
      -- code functions
      { km.copilot .. "d", ":CopilotChatDocs<CR>", mode = "v", desc = "CopilotChat Document code" },
      { km.copilot .. "e", ":CopilotChatExplain<CR>", mode = "v", desc = "CopilotChat Explain code" },
      { km.copilot .. "f", ":CopilotChatFix<CR>", mode = "v", desc = "CopilotChat Fix code" },
      { km.copilot .. "g", ":CopilotChatCommit<CR>", mode = "v", desc = "CopilotChat Commit code" },
      { km.copilot .. "o", ":CopilotChatOptimize<CR>", mode = "v", desc = "CopilotChat Optimize code" },
      { km.copilot .. "r", ":CopilotChatReview<CR>", mode = "v", desc = "CopilotChat Review code" },
      { km.copilot .. "t", ":CopilotChatTests<CR>", mode = "v", desc = "CopilotChat Tests code" },
      -- window functions
      { km.copilot .. "H", ":CopilotChatStop<CR>", mode = "n", desc = "CopilotChat Halt/Stop chat window" },
      { km.copilot .. "L", ":CopilotChatLoad ", mode = "n", desc = "CopilotChat Load chat window" },
      { km.copilot .. "M", ":CopilotChatModel<CR>", mode = "n", desc = "CopilotChat ai Models list" },
      { km.copilot .. "O", ":CopilotChatOpen<CR>", mode = "n", desc = "CopilotChat Open chat window" },
      { km.copilot .. "Q", ":CopilotChatClose<CR>", mode = "n", desc = "CopilotChat Close chat window" },
      { km.copilot .. "R", ":CopilotChatReset<CR>", mode = "n", desc = "CopilotChat Reset chat window" },
      { km.copilot .. "S", ":CopilotChatSave ", mode = "n", desc = "CopilotChat Save chat window" },
      { km.copilot .. "T", ":CopilotChatToggle<CR>", mode = "n", desc = "CopilotChat Toggle chat window" },
    },
    config = function(_, opts)
      local copilot_chat = require("CopilotChat")
      copilot_chat.setup(opts)

      vim.keymap.set({ "n", "v" }, km.copilot .. "a", function()
        copilot_chat.select_prompt()
      end, { desc = "CopilotChat prompt Actions" })

      vim.keymap.set("n", km.copilot .. "q", function()
        vim.ui.input({ prompt = "Copilot Chat: " }, function(input)
          while input == "" do
            input = vim.fn.input("Quick Chat:")
          end
          copilot_chat.ask(input, { selection = "#selection" })
        end)
      end, { desc = "CopilotChat Query" })
    end,
  },
}
