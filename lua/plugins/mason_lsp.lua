local default_language_servers = {
  "bashls",                -- BASh
  "cssls",                 -- CSS
  "dockerls",              -- Docker
  "emmet_language_server", -- HTML writing in Emmet notation
  "html",                  -- HTML
  "jsonls",                -- JSON
  "lua_ls",                -- LUA
  "basedpyright",          -- Python
  "sqlls",                 -- SQL
  "taplo",                 -- TOML
  "ts_ls",                 -- Javascript and Typescript
  "vimls",                 -- VimScript
  "yamlls",                -- YAML
}


return {

  -- Communication hooks between Neovim and LSPs
  {
    -- https://github.com/neovim/nvim-lspconfig
    "neovim/nvim-lspconfig",
    dependencies = {

      -- LSP updates as text overlay
      {
        -- https://github.com/j-hui/fidget.nvim
        "j-hui/fidget.nvim",
        opts = {}, -- NOTE: `opts = {}` is the same as calling `require("fidget").setup({})`
      },

      -- Neovim setup for init.lua and plugin development with full signature help, docs and completion for the nvim lua API.
      -- https://github.com/folke/lazydev.nvim
      -- already in programming.lua
      "folke/lazydev.nvim",

    },
    config = function()

      local lspconfig = require("lspconfig")

      -- Set global defaults for all servers
      lspconfig.util.default_config = vim.tbl_extend(
        "force",
        lspconfig.util.default_config,
        {
          capabilities = vim.tbl_deep_extend(
            "force",
            vim.lsp.protocol.make_client_capabilities(),
            -- returns configured operations if setup() was already called
            -- or default operations if not
            require("lsp-file-operations").default_capabilities()
          )
        }
      )

      -- add border to the :Lsp*-command window
      require("lspconfig.ui.windows").default_options.border = "single"

      -- Global mappings.
      -- See `:help vim.diagnostic.*` for documentation on any of the below functions
      vim.keymap.set(
        "n",
        "<leader>lw",
        vim.diagnostic.open_float,
        { desc = "Show diagnostic in a floating window" })
      vim.keymap.set(
        "n",
        "[d",
        function()
          vim.diagnostic.jump({count=-1, float=true })
        end,
        { desc = "Move to previous diagnostic in the current buffer" })
      vim.keymap.set(
        "n",
        "]d",

        function()
          vim.diagnostic.jump({count=1, float=true })
        end,
        { desc = "Move to next diagnostic in the current buffer" })
      vim.keymap.set(
        "n",
        "<leader>lq",
        vim.diagnostic.setloclist,
        { desc = "Add buffer diagnostics to the location list" })

      -- Use LspAttach autocommand to only map the following keys
      -- after the language server attaches to the current buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          -- Enable completion triggered by <c-x><c-o>
          vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

          -- Buffer local mappings.
          -- See `:help vim.lsp.*` for documentation on any of the below functions
          local opts = { buffer = ev.buf }

          -- symbols
          vim.keymap.set(
            "n",
            "gD",
            vim.lsp.buf.declaration,
            vim.tbl_extend("error", { desc = "Jump to Declaration of symbol" }, opts))
          vim.keymap.set(
            "n",
            "gd",
            vim.lsp.buf.definition,
            vim.tbl_extend("error", { desc = "Jump to Definition of symbol" }, opts))
          vim.keymap.set(
            "n",
            "K",
            vim.lsp.buf.hover,
            vim.tbl_extend("error", { desc = "Display information about symbol" }, opts))
          vim.keymap.set(
            "n",
            "gi",
            vim.lsp.buf.implementation,
            vim.tbl_extend("error", { desc = "Jump to Implementation of symbol" }, opts))
          vim.keymap.set(
            "n", "<leader>li",
            vim.lsp.buf.incoming_calls,
            { desc = "Incoming calls for Symbol" })
          vim.keymap.set(
            "n", "<leader>lo",
            vim.lsp.buf.outgoing_calls,
            { desc = "Outgoing calls for Symbol" })
          vim.keymap.set(
            "n", "<leader>lk",
            vim.lsp.buf.signature_help,
            vim.tbl_extend("error", { desc = "Show the Signature of symbol" }, opts))
          vim.keymap.set(
            "n",
            "<leader>lt",
            vim.lsp.buf.type_definition,
            vim.tbl_extend("error", { desc = "Show Type of symbol" }, opts))
          vim.keymap.set(
            "n",
            "<leader>lr",
            vim.lsp.buf.rename,
            vim.tbl_extend("error", { desc = "Rename symbol" }, opts))
          vim.keymap.set(
            { "n", "v" },
            "<leader>la",
            vim.lsp.buf.code_action,
            vim.tbl_extend("error", { desc = "Code Actions" }, opts))
          vim.keymap.set(
            "n",
            "gr",
            vim.lsp.buf.references,
            vim.tbl_extend("error", { desc = "Show References to symbol" }, opts))
          vim.keymap.set(
            "n", "<leader>lf",
            function()
              vim.lsp.buf.format({ async = true })
            end,
            vim.tbl_extend("error", { desc = "Format buffer" }, opts))

          -- workspace
          vim.keymap.set(
            "n", "<leader>wa",
            vim.lsp.buf.add_workspace_folder,
            vim.tbl_extend("error", { desc = "Add Folder to workspace" }, opts))
          vim.keymap.set(
            "n", "<leader>wr",
            vim.lsp.buf.remove_workspace_folder,
            vim.tbl_extend("error", { desc = "Remove Folder from workspace" }, opts))
          vim.keymap.set(
            "n", "<leader>wl",
            function()
              print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            end,
            vim.tbl_extend("error", { desc = "Show list of Folders in workspace" }, opts))
        end,
      })
    end,
  },

  -- LSP, DAP, Linters and Formatters manager
  {
    -- https://github.com/williamboman/mason.nvim
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ui = { border = "single" },
      })
    end,
  },

  -- Bridge for LSPs installed using Mason
  {
    -- https://github.com/williamboman/mason-lspconfig.nvim
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    dependencies = {
      { "williamboman/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
    config = function()
      -- local lspconfig = require("lspconfig")
      -- local capabilities = require("cmp_nvim_lsp").default_capabilities()
      -- local border = {
      --   {"🭽", "FloatBorder"},
      --   {"▔", "FloatBorder"},
      --   {"🭾", "FloatBorder"},
      --   {"▕", "FloatBorder"},
      --   {"🭿", "FloatBorder"},
      --   {"▁", "FloatBorder"},
      --   {"🭼", "FloatBorder"},
      --   {"▏", "FloatBorder"},
      -- }

      require("mason-lspconfig").setup({
        automatic_enable = true,
        automatic_installation = true,
        ensure_installed = default_language_servers,
      })

      vim.lsp.config("basedpyright", {
        cmd = { "basedpyright-langserver", "--stdio", "--verbose" },
        root_uri = function(bufnr)
          local root = vim.fs.root(bufnr, { ".git", "__init__.py", "pyproject.toml", "setup.py", "pyrightconfig.json" })
          return root and vim.uri_from_fname(root) or nil
        end,
        settings = {
          basedpyright = {
            analysis = {
              autoImportCompletions = true,
              autoSearchPaths = true,
              diagnosticMode = "workspace",
              -- extraPaths = {},
              -- include = {},
              inlayHints = {
                genericTypes = true
              },
              logLevel = "Information",
              typeCheckingMode = "recommended",
            },
          },
        },
      })

      vim.keymap.set("n", "<leader>lk", function()
        vim.lsp.buf.hover({ border = "rounded", focusable = false })
      end, { desc = "LSP Hover (Rounded)" })

      vim.keymap.set("i", "<C-k>", function()
        vim.lsp.buf.signature_help({ border = "rounded", focusable = false })
      end, { desc = "LSP Signature Help" })

      -- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization
      -- diagnostic beahviour and look
      vim.diagnostic.config({
        signs = true,
        underline = true,
        update_in_insert = true,
        severity_sort = false,
        virtual_text = true,
        float = true,
      })
      local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      -- diagnostics on hover @ cursor position
      -- vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      --   group = vim.api.nvim_create_augroup("float_diagnostic_cursor", { clear = true }),
      --   callback = function ()
      --     vim.diagnostic.open_float(nil, {focus=false, scope="cursor"})
      --   end
      -- })
    end,
  },

  -- LSP renaming with immediate visual feedback
  {
    -- https://github.com/smjonas/inc-rename.nvim
    "smjonas/inc-rename.nvim",
    config = function()
      require("inc_rename").setup({})

      vim.keymap.set(
        "n", "<leader>rs",
        ":IncRename ",
        { desc = "IncRename: Symbol" })

      vim.keymap.set(
        "n", "<leader>rw",
        function()
          return ":IncRename " .. vim.fn.expand("<cword>")
        end,
        { expr = true, desc = "IncRename: Symbol under cursor" })
    end,
  },

}
