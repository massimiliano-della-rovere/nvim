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
        -- automatic_enable = {
        --   exclude = { "basedpyright" },
        -- },
        automatic_installation = true,
        ensure_installed = default_language_servers,
      })

      local neotree_utils = require("neo-tree.utils")
      -- local nvim_lspconfig = require("lspconfig")
      -- local default_cfg = nvim_lspconfig.lsp.basedpyright
      -- vim.inspect(default_cfg)
      vim.lsp.config("basedpyright", {
        filetypes = { "python" },
        cmd = { "basedpyright-langserver", "--stdio", "--verbose" },
        -- "__init__.py", 
        root_markers = { ".git", "pyproject.toml", "setup.py", "pyrightconfig.json" },
        settings = {
          python = {
            pythonPath = neotree_utils.path_join(
              os.getenv("VIRTUAL_ENV"), "bin", "python"
            ),
          },
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

      -- local oop_group = vim.api.nvim_create_augroup("OOP", { clear = true })
      -- function _G.oop_debug_callback(args)
      --   print("OOP: " .. args.event .. " -> " .. string.format(vim.inspect(args)))
      -- end

      --   pattern = "python",
      --   callback = function(args)
      --     vim.api.nvim_create_autocmd({ "LspProgress" }, {
      --       group = oop_group,
      --       -- pattern = {"begin", "report", "end"},
      --       pattern = { "end" },
      --       callback = _G.oop_debug_callback,
      --     })
      --     vim.api.nvim_create_autocmd({ "LspNotify", "LspTokenUpdate" }, {
      --       group = oop_group,
      --       callback = _G.oop_debug_callback,
      --     })
      --     vim.api.nvim_create_autocmd({ "LspRequest" }, {
      --       group = oop_group,
      --       -- pattern = {"begin", "report", "end"},
      --       pattern = { "complete" },
      --       callback = _G.oop_debug_callback,
      --     })
      --   end
      -- })

      -- --------------------------------------------------------------------------------
      -- -- 1. ANALISI STATICA (Treesitter) - "Guardo in alto" (Override)
      -- --------------------------------------------------------------------------------
      -- function _G.check_is_override(bufnr, method_node)
      --   local is_override = false
      --   local parent = method_node:parent()
      --
      --   while parent do
      --     if parent:type() == "class_definition" then
      --       local superclasses = parent:child_by_field_name("superclasses")
      --       if superclasses then 
      --         is_override = true 
      --       end
      --       break
      --     end
      --     parent = parent:parent()
      --   end
      --
      --   return is_override
      -- end
      --
      -- --------------------------------------------------------------------------------
      -- -- 2. ANALISI DINAMICA (LSP) - "Guardo in basso" (Implementation)
      -- --------------------------------------------------------------------------------
      -- -- CORREZIONE: Ora accetta 'node' per calcolare la posizione precisa
      -- function _G.check_has_children(client, bufnr, method_name, node, start_row, callback)
      --
      --   -- Creiamo i parametri manualmente puntando al NODO, non al cursore.
      --   -- Se usassimo make_position_params() qui, l'LSP cercherebbe info
      --   -- sulla posizione attuale del mouse/cursore, non sul metodo del loop!
      --   local _, start_col = node:range()
      --   local params = {
      --     textDocument = vim.lsp.util.make_text_document_params(bufnr),
      --     position = { line = start_row, character = start_col }
      --   }
      --
      --   client.request("textDocument/implementation", params, function(err, result)
      --     if err then
      --       -- M.log("Err LSP ("..method_name.."): " .. err.message, vim.log.levels.ERROR)
      --       callback(false)
      --       return
      --     end
      --
      --     if not result or vim.tbl_isempty(result) then
      --       callback(false)
      --       return
      --     end
      --
      --     local has_real_children = false
      --     local current_uri = vim.uri_from_bufnr(bufnr)
      --     local locations = vim.islist(result) and result or {result}
      --
      --     for _, loc in ipairs(locations) do
      --       local is_same_file = (loc.uri == current_uri)
      --       local is_same_line = (loc.range.start.line == start_row)
      --
      --       -- È un figlio se non è la definizione stessa
      --       if not (is_same_file and is_same_line) then
      --         has_real_children = true
      --         -- M.log("Figlio trovato per " .. method_name)
      --         break 
      --       end
      --     end
      --
      --     callback(has_real_children)
      --   end, bufnr)
      -- end
      --
      -- --------------------------------------------------------------------------------
      -- -- 3. LOGICA UI
      -- --------------------------------------------------------------------------------
      -- function _G.place_sign(bufnr, row, is_override, has_children)
      --   local sign_name = nil
      --
      --   if is_override and has_children then
      --     sign_name = "LspMiddle"
      --   elseif is_override then
      --     sign_name = "LspOverride"
      --   elseif has_children then
      --     sign_name = "LspImplementation"
      --   end
      --
      --   if sign_name then
      --     vim.fn.sign_place(0, 'inheritance_signs', sign_name, bufnr, {
      --       lnum = row + 1, priority = 90
      --     })
      --   end
      -- end
      --
      -- --------------------------------------------------------------------------------
      -- -- 4. ORCHESTRATORE PRINCIPALE
      -- --------------------------------------------------------------------------------
      -- function _G.refresh_signs()
      --   local bufnr = vim.api.nvim_get_current_buf()
      --
      --   local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "basedpyright" })
      --   if #clients == 0 then return end
      --   local client = clients[1]
      --
      --   local parser = vim.treesitter.get_parser(bufnr, "python")
      --   if not parser then return end
      --
      --   local tree = parser:parse()[1]
      --   local query = vim.treesitter.query.parse("python", [[
      --   (function_definition name: (identifier) @method_name) @method_def
      --   ]])
      --
      --   vim.fn.sign_unplace('inheritance_signs', { buffer = bufnr })
      --
      --   for id, node in query:iter_captures(tree:root(), bufnr, 0, -1) do
      --     local capture_name = query.captures[id]
      --     if capture_name == "method_name" then
      --       local name = vim.treesitter.get_node_text(node, bufnr)
      --       if name == "__init__" then goto continue end
      --
      --       local start_row, _ = node:range()
      --
      --       -- 1. Calcolo Override (Sincrono)
      --       local is_override = _G.check_is_override(bufnr, node)
      --
      --       -- 2. Calcolo Implementation (Asincrono)
      --       -- ORA CHIAMIAMO LA FUNZIONE CORRETTA
      --       _G.check_has_children(client, bufnr, name, node, start_row, function(has_children)
      --
      --         -- 3. Piazzamento Segno (Callback)
      --         _G.place_sign(bufnr, start_row, is_override, has_children)
      --
      --       end)
      --     end
      --     ::continue::
      --   end
      -- end
      --
      -- --------------------------------------------------------------------------------
      -- -- 5. GESTORE CLICK
      -- --------------------------------------------------------------------------------
      -- function _G.handle_click(args)
      --   if not args or not args.mousepos then return end
      --   local line = args.mousepos.line
      --   local bufnr = vim.api.nvim_get_current_buf()
      --
      --   local signs = vim.fn.sign_getplaced(bufnr, { group = 'inheritance_signs', lnum = line })
      --   if #signs == 0 or #signs[1].signs == 0 then return end
      --   local sign_name = signs[1].signs[1].name
      --
      --   local node = vim.treesitter.get_node({ bufnr = bufnr, pos = {line - 1, 0} })
      --   while node and node:type() ~= "function_definition" do node = node:parent() end
      --
      --   if node then
      --     local name_node = node:child_by_field_name("name")
      --     if name_node then
      --       local r, c = name_node:range()
      --       vim.api.nvim_win_set_cursor(0, {r + 1, c})
      --
      --       vim.defer_fn(function()
      --         if sign_name == "LspOverride" or sign_name == "LspMiddle" then
      --           vim.notify("Go Up (Definition)")
      --           vim.lsp.buf.definition()
      --         elseif sign_name == "LspImplementation" then
      --           vim.notify("Go Down (Implementation)")
      --           vim.lsp.buf.implementation()
      --         end
      --       end, 20)
      --     end
      --   end
      -- end

      -- vim.api.nvim_create_autocmd("FileType", {
      --   pattern = "python",
      --   callback = function(args)
      --     -- Abilita il config "basedpyright" definito sopra
      --     vim.lsp.enable("basedpyright")
      --
      --     -- Colleghiamo la logica OOP quando l'LSP è attivo
      --     -- local client = vim.lsp.get_clients({ bufnr = args.buf, name = "basedpyright" })[1]
      --     -- local client = vim.lsp.get_clients({ bufnr = args.buf, name = "jedi_language_server" })[1]
      --     -- if client then
      --     --   -- vim.notify("Basedpyright Nativo 0.11 attivato")
      --     --
      --     --   -- Autocommand per i segni (OOP)
      --     --   local group = vim.api.nvim_create_augroup("OOP_Signs_" .. args.buf, { clear = true })
      --     --   vim.api.nvim_create_autocmd({"BufEnter", "BufWritePost"}, {
      --     --     group = group,
      --     --     buffer = args.buf,
      --     --     callback = function(args)
      --     --       print("OOP: " .. args.event .. " -> " .. string.format(vim.inspect(args)))
      --     --       -- vim.defer_fn(_G.refresh_signs, 500)
      --     --     end,
      --     --   })
      --     --
      --     --   -- -- Mappatura Click (Mouse)
      --     --   vim.keymap.set("n", "<LeftMouse>", function()
      --     --     local mouse = vim.fn.getmousepos()
      --     --     if mouse.screencol <= 2 then 
      --     --       _G.handle_click({ mousepos = mouse })
      --     --     end
      --     --     return vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<LeftMouse>", true, false, true), "n", true)
      --     --   end, { buffer = args.buf })
      --     --
      --     --   -- Refresh iniziale
      --     --   _G.refresh_signs()
      --     -- end
      --   end,
      -- })

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
