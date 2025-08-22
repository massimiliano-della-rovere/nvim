local default_language_servers = {
  "bashls",                -- BASh
  "cssls",                 -- CSS
  "dockerls",              -- Docker
  "emmet_language_server", -- HTML writing in Emmet notation
  "html",                  -- HTML
  "jsonls",                -- JSON
  "lua_ls",                -- LUA
  "pyright",               -- Python
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
        opts = {}, -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      },

      -- Neovim setup for init.lua and plugin development with full signature help, docs and completion for the nvim lua API.
      -- https://github.com/folke/neodev.nvim
      -- already in programming.lua
      "folke/neodev.nvim",

    },
    config = function()

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
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local border = {
        {"🭽", "FloatBorder"},
        {"▔", "FloatBorder"},
        {"🭾", "FloatBorder"},
        {"▕", "FloatBorder"},
        {"🭿", "FloatBorder"},
        {"▁", "FloatBorder"},
        {"🭼", "FloatBorder"},
        {"▏", "FloatBorder"},
      }

      -- LSP settings (for overriding per client)
      local handlers =  {
        ["textDocument/hover"] = vim.lsp.buf.hover({ border = border }),
        ["textDocument/signatureHelp"] = vim.lsp.buf.signature_help({ border = border }),
      }

      require("mason-lspconfig").setup({
        automatic_installation = true,
        ensure_installed = default_language_servers,
        handlers = {
          function (server_name)
            -- from :help mason-lspconfig.setup_handlers()
            -- ===========================================
            -- Register the provided {handlers}, to be called by mason when
            -- an installed server supported by lspconfig is ready to be
            -- set up.
            -- 
            --  ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
            -- → When this function is called, all servers that are          ←
            -- → currently installed will be considered ready to be set up.  ←
            -- → When a new server is installed during a session, it will be ←
            -- → considered ready to be set up when installation succeeds.   ←
            --  ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
            --
            -- {handlers} is a table where the keys are the name of an
            -- lspconfig server, and the values are the function to be
            -- called when that server is ready to be set up
            -- (i.e. is installed).
            --
            -- You may also pass a default handler that will be called
            -- when no dedicated handler is provided.
            -- This is done by providing a function without a key
            -- (see example below).

            -- from autocompletion.lua:
            -- ========================
            -- The nvim-cmp almost supports LSP's capabilities,
            -- so You should advertise it to LSP servers..
            local util = require("lspconfig/util")

            local path = util.path

            -- local function get_python_path(workspace)
            --   -- Use activated virtualenv.
            --   if vim.env.VIRTUAL_ENV then
            --     return path.join(vim.env.VIRTUAL_ENV, "bin", "python")
            --   end
            --
            --   -- Find and use virtualenv from pipenv in workspace directory.
            --   local match = vim.fn.glob(path.join(workspace, "Pipfile"))
            --   if match ~= "" then
            --     local venv = vim.fn.trim(vim.fn.system("PIPENV_PIPFILE=" .. match .. " pipenv --venv"))
            --     return path.join(venv, "bin", "python")
            --   end
            --
            --   -- Fallback to system Python.
            --   return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
            -- end

            local setup_args = {
              capabilities = capabilities,
              handlers = handlers,
              on_attach = function(client, bufnr)
                vim.api.nvim_create_autocmd("CursorHold", {
                  buffer = bufnr,
                  callback = function()
                    local opts = {
                      focusable = false,
                      close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                      border = "rounded",
                      source = "always",
                      prefix = " ",
                      scope = "cursor",
                    }
                    vim.diagnostic.open_float(nil, opts)
                  end
                })
              end,
            }
            -- if server_name == "pyright" then
            --   setup_args.root_dir = function (fname)
            --     if string.match(fname, "/tcwa/code/tcwa2") then
            --       return "/tcwa/code/tcwa2/code/backend"
            --     elseif string.match(fname, "/tcwa/code") then
            --       return "/tcwa/code"
            --     else 
            --       return "/"
            --   end
            -- end
            lspconfig[server_name].setup(setup_args)
          end
        }
      })

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
      require("inc_rename").setup()

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
