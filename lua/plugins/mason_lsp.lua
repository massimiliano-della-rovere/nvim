-- ============================================================
-- plugins/mason_lsp.lua  --  Neovim 0.12 / 0.13-compatible
-- ============================================================
-- Architettura LSP:
--
--   mason-org/mason.nvim          installa i binari degli LSP
--   mason-org/mason-lspconfig     mappa nomi mason <-> lspconfig,
--                                 chiama vim.lsp.enable() per i
--                                 server installati
--   neovim/nvim-lspconfig         fornisce definizioni base dei
--                                 server, legge lsp/<server>.lua
--   lua/lsp/<server>.lua          un file per server, restituisce
--                                 una tabella di configurazione
--
-- Bordo hover/signatureHelp:
--   In 0.12+ vim.lsp.with() e vim.lsp.handlers.* sono deprecati.
--   Il bordo viene passato direttamente nelle funzioni chiamate
--   dai keymap:  vim.lsp.buf.hover({ border = ... })
--   Questo e' l'unico pattern compatibile con 0.13.
-- ============================================================

local km = require("keymaps") -- prefissi centralizzati
local BORDER = "single"

local mason_servers = {
  "bashls", -- Bash          → lsp/bashls.lua
  "cssls", -- CSS           → lsp/cssls.lua
  "dockerls", -- Docker        → lsp/dockerls.lua
  "emmet_language_server", -- Emmet/HTML    → lsp/emmet_language_server.lua
  "html", -- HTML          → lsp/html.lua
  "jsonls", -- JSON          → lsp/jsonls.lua
  "lua_ls", -- Lua           → lsp/lua_ls.lua
  "basedpyright", -- Python        → lsp/basedpyright.lua
  "sqlls", -- SQL           → lsp/sqlls.lua
  "taplo", -- TOML          → lsp/taplo.lua
  "ts_ls", -- TS/JS         → lsp/ts_ls.lua
  "vimls", -- VimScript     → lsp/vimls.lua
  "yamlls", -- YAML          → lsp/yamlls.lua
}

return {

  -- ── nvim-lspconfig ───────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "j-hui/fidget.nvim", opts = {} },
      "folke/lazydev.nvim",
      "b0o/schemastore.nvim", -- JSON/YAML schema catalog
    },
    config = function()
      -- Capabilities globali: nvim-cmp + lsp-file-operations + nvim-ufo
      local capabilities = vim.tbl_deep_extend(
        "force",
        vim.lsp.protocol.make_client_capabilities(),
        require("lsp-file-operations").default_capabilities()
      )
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      }
      vim.lsp.config("*", { capabilities = capabilities })

      -- Bordo finestra :LspInfo
      require("lspconfig.ui.windows").default_options.border = BORDER

      -- ── Diagnostic keymaps (globali, senza LspAttach) ────
      vim.keymap.set("n", km.lsp .. "w", vim.diagnostic.open_float, { desc = "LSP: floating diagnostic" })
      vim.keymap.set("n", "[d", function()
        vim.diagnostic.jump({ count = -1, float = true })
      end, { desc = "LSP: prev diagnostic" })
      vim.keymap.set("n", "]d", function()
        vim.diagnostic.jump({ count = 1, float = true })
      end, { desc = "LSP: next diagnostic" })
      vim.keymap.set("n", km.lsp .. "q", vim.diagnostic.setloclist, { desc = "LSP: diagnostics to loclist" })

      -- ── Keymaps buffer-local (LspAttach) ─────────────────
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = function(ev)
          vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
          local buf = { buffer = ev.buf }
          local function e(desc)
            return vim.tbl_extend("force", { desc = desc }, buf)
          end

          -- Navigazione simboli
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, e("LSP: Declaration"))
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, e("LSP: Definition"))
          -- 0.12 default: gri → implementation; gi per abitudine
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, e("LSP: Implementation"))
          vim.keymap.set("n", km.lsp .. "t", vim.lsp.buf.type_definition, e("LSP: Type definition"))
          -- 0.12 default: grr → references
          vim.keymap.set("n", "gr", vim.lsp.buf.references, e("LSP: References"))

          -- Hover e signature: bordo passato per-chiamata.
          -- Forma idiomatica 0.12+/0.13: nessun override globale su
          -- vim.lsp.handlers.* ne' uso di vim.lsp.with().
          vim.keymap.set("n", "K", function()
            vim.lsp.buf.hover({ border = BORDER })
          end, e("LSP: Hover"))
          vim.keymap.set("n", km.lsp .. "k", function()
            vim.lsp.buf.hover({ border = "rounded", focusable = false })
          end, e("LSP: Hover (rounded)"))
          vim.keymap.set("i", "<C-k>", function()
            vim.lsp.buf.signature_help({ border = BORDER })
          end, e("LSP: Signature help"))

          -- Call hierarchy
          vim.keymap.set("n", km.lsp .. "i", vim.lsp.buf.incoming_calls, e("LSP: Incoming calls"))
          vim.keymap.set("n", km.lsp .. "o", vim.lsp.buf.outgoing_calls, e("LSP: Outgoing calls"))

          -- Rename / code action / format
          -- 0.12 default: grn → rename, gra → code_action
          vim.keymap.set("n", km.lsp .. "r", vim.lsp.buf.rename, e("LSP: Rename"))
          vim.keymap.set({ "n", "v" }, km.lsp .. "a", vim.lsp.buf.code_action, e("LSP: Code action"))
          vim.keymap.set("n", km.lsp .. "f", function()
            vim.lsp.buf.format({ async = true })
          end, e("LSP: Format buffer"))

          -- Inlay hints
          vim.keymap.set("n", km.lsp .. "H", function()
            local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf })
            vim.lsp.inlay_hint.enable(not enabled, { bufnr = ev.buf })
          end, e("LSP: Toggle inlay hints"))

          -- Code lens
          -- 0.12+: codelens.refresh accetta { bufnr } per limitare al buffer
          vim.keymap.set("n", km.lsp .. "L", function()
            vim.lsp.codelens.run()
          end, e("LSP: Run codelens"))
          vim.keymap.set("n", km.lsp .. "R", function()
            vim.lsp.codelens.refresh({ bufnr = ev.buf })
          end, e("LSP: Refresh codelens"))

          -- Workspace folders
          vim.keymap.set("n", km.workspace .. "a", vim.lsp.buf.add_workspace_folder, e("LSP: Add workspace folder"))
          vim.keymap.set(
            "n",
            km.workspace .. "r",
            vim.lsp.buf.remove_workspace_folder,
            e("LSP: Remove workspace folder")
          )
          vim.keymap.set("n", km.workspace .. "l", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, e("LSP: List workspace folders"))
        end,
      })
    end,
  },

  -- ── Mason ─────────────────────────────────────────────────
  {
    "mason-org/mason.nvim",
    config = function()
      require("mason").setup({ ui = { border = "single" } })
    end,
  },

  -- ── mason-lspconfig ───────────────────────────────────────
  -- automatic_enable = true: chiama vim.lsp.enable() per ogni
  -- server installato, che a sua volta carica lsp/<server>.lua.
  {
    "mason-org/mason-lspconfig.nvim",
    lazy = false,
    dependencies = {
      "folke/lazydev.nvim",
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason-lspconfig").setup({
        automatic_enable = true,
        automatic_installation = true,
        ensure_installed = mason_servers,
      })
    end,
  },

  -- ── LSP file operations (neo-tree rename/move) ────────────
  {
    "antosha417/nvim-lsp-file-operations",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-neo-tree/neo-tree.nvim" },
    config = function()
      require("lsp-file-operations").setup()
    end,
  },

  -- ── Rename con anteprima visiva ───────────────────────────
  {
    "smjonas/inc-rename.nvim",
    config = function()
      require("inc_rename").setup({})
      vim.keymap.set("n", km.rename .. "s", ":IncRename ", { desc = "IncRename: symbol" })
      vim.keymap.set("n", km.rename .. "w", function()
        return ":IncRename " .. vim.fn.expand("<cword>")
      end, { expr = true, desc = "IncRename: word under cursor" })
    end,
  },
}
