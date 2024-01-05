FILE_EXTENSIONS_EXCLUDED_FROM_CTAGS_GENERATION = {
  "*.git", "*.svg", "*.hg",
  "*/tests/*",
  "build",
  "dist",
  "*sites/*/files/*",
  "bin",
  "node_modules",
  "bower_components",
  "cache",
  "compiled",
  "docs",
  "example",
  "bundle",
  "vendor",
  "*.md",
  "*-lock.json",
  "*.lock",
  "*bundle*.js",
  "*build*.js",
  ".*rc*",
  "*.json",
  "*.min.*",
  "*.map",
  "*.bak",
  "*.zip",
  "*.pyc",
  "*.class",
  "*.sln",
  "*.Master",
  "*.csproj",
  "*.tmp",
  "*.csproj.user",
  "*.cache",
  "*.pdb",
  "tags*",
  "cscope.*",
  "*.css",
  "*.less",
  "*.scss",
  "*.exe", "*.dll",
  "*.mp3", "*.ogg", "*.flac",
  "*.swp", "*.swo",
  "*.bmp", "*.gif", "*.ico", "*.jpg", "*.png",
  "*.rar", "*.zip", "*.tar", "*.tar.gz", "*.tar.xz", "*.tar.bz2",
  "*.pdf", "*.doc", "*.docx", "*.ppt", "*.pptx"
}

return {
  -- Detect tabstop and shiftwidth automatically
  "tpope/vim-sleuth",

  -- comment/uncomment code
  {
    'terrortylor/nvim-comment',
    config = function()
      require('nvim_comment').setup()
    end
  },

  -- "gc"/"gb" to comment visual regions/lines
  -- { 'numToStr/Comment.nvim', opts = {} },


  {
    -- Autocompletion
    "hrsh7th/nvim-cmp",
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",

      -- Adds LSP completion capabilities
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",

      -- Adds a number of user-friendly snippets
      "rafamadriz/friendly-snippets",

      -- icons in the menu
      "onsails/lspkind.nvim",
    },
    config = function()
      require("cmp").setup({
        formatting = {
          format = function(entry, vim_item)
            vim_item.menu = ({
              rg = "[Rg]",
              buffer = "[Buffer]",
              nvim_lsp = "[LSP]",
              vsnip = "[Snippet]",
              tags = "[Tag]",
              path = "[Path]",
              orgmode = "[Org]",
              ["vim-dadbod-completion"] = "[DB]",
            })[entry.source.name]
            return vim_item
          end,
        },
        sources = {
          { name = "nvim_lsp" },
          { name = "vsnip" },
          { name = "buffer" },
          { name = "tags", keyword_length = 2 },
          { name = "rg", keyword_length = 3 },
          { name = "path" },
          { name = "orgmode" },
        },
        -- snippet = {
        --   expand = function(args)
        --     vim.fn["vsnip#anonymous"](args.body)
        --   end,
        -- },
        -- mapping = cmp.mapping.preset.insert({
        --   ["<CR>"] = function(fallback)
        --     if vim.fn["vsnip#expandable"]() ~= 0 then
        --       vim.fn.feedkeys(utils.esc("<Plug>(vsnip-expand)"), "")
        --       return
        --     end
        --     return cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace })(fallback)
        --   end,
        --   ["<C-Space>"] = cmp.mapping(
        --     cmp.mapping.complete({
        --       config = {
        --         sources = {
        --           { name = "nvim_lsp" },
        --           { name = "path" },
        --         },
        --       },
        --     }),
        --     { "i" }
        --   ),
        --   ["<Tab>"] = cmp.mapping(function()
        --     if vim.fn["vsnip#jumpable"](1) > 0 then
        --       vim.fn.feedkeys(utils.esc("<Plug>(vsnip-jump-next)"), "")
        --     elseif vim.fn["vsnip#expandable"]() > 0 then
        --       vim.fn.feedkeys(utils.esc("<Plug>(vsnip-expand)"), "")
        --     else
        --       vim.api.nvim_feedkeys(
        --         vim.fn["copilot#Accept"](vim.api.nvim_replace_termcodes("<Tab>", true, true, true)),
        --         "n",
        --         true
        --       )
        --     end
        --   end, { "i", "s" }),
        --
        --   ["<S-Tab>"] = cmp.mapping(function(fallback)
        --     if vim.fn["vsnip#jumpable"](-1) == 1 then
        --       vim.fn.feedkeys(utils.esc("<Plug>(vsnip-jump-prev)"), "")
        --     else
        --       fallback()
        --     end
        --   end, { "i", "s" }),
        -- }),
        -- window = {
        --   documentation = {
        --     border = "rounded",
        --   },
        -- },
      })
    end
  },

  {
    -- LSP Configuration & Plugins
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      {
        "williamboman/mason.nvim",
        config = function()
          require("mason").setup()
        end
      },
      {
        "williamboman/mason-lspconfig.nvim",
        config = function()
          local mason_lspconfig = require("mason-lspconfig")
          mason_lspconfig.setup()
          -- Enable the following language servers
          --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
          --
          --  Add any additional override configuration in the following tables. They will be passed to
          --  the `settings` field of the server config. You must look up that documentation yourself.
          --
          --  If you want to override the default filetypes that your language server will attach to you can
          --  define the property "filetypes" to the map in question.
          local servers = {
            -- clangd = {},
            -- gopls = {},
            -- pyright = {},
            -- rust_analyzer = {},
            -- tsserver = {},
            -- html = { filetypes = { "html", "twig", "hbs"} },

            lua_ls = {
              Lua = {
                workspace = { checkThirdParty = false },
                telemetry = { enable = false },
                -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
                -- :warnings = { disable = { "missing-fields" } },
              },
            },
          }
          -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
          local capabilities = vim.lsp.protocol.make_client_capabilities()
          capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

          -- Ensure the servers above are installed
          mason_lspconfig.setup({
            ensure_installed = vim.tbl_keys(servers),
          })

          mason_lspconfig.setup_handlers({
            function(server_name)
              require("lspconfig")[server_name].setup {
                capabilities = capabilities,
                on_attach = on_attach,
                settings = servers[server_name],
                filetypes = (servers[server_name] or {}).filetypes,
              }
            end,
          })
        end
      },

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require("fidget").setup({})`
      { "j-hui/fidget.nvim", opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      {
        "folke/neodev.nvim",
        config = function()
          -- Setup neovim lua configuration
          require("neodev").setup()
        end
      }
    },
    config = function()
      -- [[ Configure nvim-cmp ]]
      -- See `:help cmp`
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()
      luasnip.config.setup({})

      cmp.setup({
        formatting = {
          format = require("lspkind").cmp_format({ mode = "symbol_text" }),
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = {
          completeopt = "menu,menuone,noinsert"
        },
        mapping = cmp.mapping.preset.insert {
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete {},
          ["<CR>"] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          },
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        },
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
        },
      })
      if not string.find(vim.g.colors_name, "^kanagawa") then
        -- gray
        vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { bg="NONE", strikethrough=true, fg="#808080" })
        -- blue
        vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { bg="NONE", fg="#569CD6" })
        vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { link="CmpIntemAbbrMatch" })
        -- light blue
        vim.api.nvim_set_hl(0, "CmpItemKindVariable", { bg="NONE", fg="#9CDCFE" })
        vim.api.nvim_set_hl(0, "CmpItemKindInterface", { link="CmpItemKindVariable" })
        vim.api.nvim_set_hl(0, "CmpItemKindText", { link="CmpItemKindVariable" })
        -- pink
        vim.api.nvim_set_hl(0, "CmpItemKindFunction", { bg="NONE", fg="#C586C0" })
        vim.api.nvim_set_hl(0, "CmpItemKindMethod", { link="CmpItemKindFunction" })
        -- front
        vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { bg="NONE", fg="#D4D4D4" })
        vim.api.nvim_set_hl(0, "CmpItemKindProperty", { link="CmpItemKindKeyword" })
        vim.api.nvim_set_hl(0, "CmpItemKindUnit", { link="CmpItemKindKeyword" })
      end
    end
  },

  -- highlight match symbol area
  -- must be after colorscheme
  {
    "rareitems/hl_match_area.nvim",
    config = function()
      require("hl_match_area").setup({
        highlight_in_insert_mode = true, -- should highlighting also be done in insert mode
        delay = 100, -- delay before the highglight
      })
      if not vim.startswith(vim.g.colors_name, "kanagawa") then
        vim.api.nvim_set_hl(0, "MatchArea", { bg = "#4A2400" })
      end
    end
  },

  -- programming breadcrumbs
  {
    "nvimdev/lspsaga.nvim",
    build = ":TSInstall markdown markdown_inline",  -- :TSInstall markdown
    config = function()
      -- required by :Lspsaga hover_doc
      require("lspsaga").setup({})

      vim.api.nvim_set_keymap(
        "n",
        "<leader>la",
        ":Lspsaga code_action<CR>",
        { noremap = true, desc = "[L]SPSaga Code [A]ction" })

      vim.api.nvim_set_keymap(
        "n",
        "<leader>lh",
        ":Lspsaga hover_doc<CR>",
        { noremap = true, desc = "[L]SPSaga [H]over" })

      vim.api.nvim_set_keymap(
        "n",
        "<leader>lci",

        ":Lspsaga incoming_calls<CR>",
        { noremap = true, desc = "[L]SPSaga [I]ncoming [C]alls" })

      vim.api.nvim_set_keymap(
        "n",
        "<leader>lco",
        ":Lspsaga outgoing_calls<CR>",
        { noremap = true, desc = "[L]SPSaga [O]utgoing [C]alls" })
      vim.api.nvim_set_keymap(
        "n",
        "<leader>lpd",
        ":Lspsaga peek_definition<CR>",
        { noremap = true, desc = "[L]SPSaga [P]eek [D]efinition" })

      vim.api.nvim_set_keymap(
        "n",
        "<leader>lpt",
        ":Lspsaga peek_type_definition<CR>",
        { noremap = true, desc = "[L]SPSaga [P]eek [T]ype Definition" })

      vim.api.nvim_set_keymap(
        "n",
        "<leader>lgd",
        ":Lspsaga goto_definition <CR>",
        { noremap = true, desc = "[L]SPSaga [G]o to [D]efinition" })

      vim.api.nvim_set_keymap(
        "n",
        "<leader>lgt",
        ":Lspsaga goto_type_definition<CR>",
        { noremap = true, desc = "[L]SPSaga [G]o to [T]ype definition" })

      vim.api.nvim_set_keymap(
        "n",
        "<leader>]e",
        ":Lspsaga diagnostic_jump_next<CR>",
        { noremap = true, desc = "[L]SPSaga jump to next [E]rror" })

      vim.api.nvim_set_keymap(
        "n",
        "<leader>[e",
        ":Lspsaga diagnostic_jump_prev<CR>",
        { noremap = true, desc = "[L]SPSaga jump to prev [E]rror" })

      vim.api.nvim_set_keymap(
        "n",
        "<leader>l]e",
        ":Lspsaga diagnostic_jump_next<CR>",
        { noremap = true, desc = "[L]SPSaga jump to next [E]rror" })

      vim.api.nvim_set_keymap(
        "n",
        "<leader>l[e",
        ":Lspsaga diagnostic_jump_prev<CR>",
        { noremap = true, desc = "[L]SPSaga jump to prev [E]rror" })

      vim.api.nvim_set_keymap(
        "n",
        "<leader>lf",
        ":Lspsaga finder<CR>",
        { noremap = true, desc = "[L]spsaga [F]inder" })

      vim.api.nvim_set_keymap(
        "n",
        "<leader>lt",
        ":Lspsaga term_toggle<CR>",
        { noremap = true, desc = "[L]spsaga [T]erminal" })

      vim.api.nvim_set_keymap(
        "n",
        "<leader>lo",
        ":Lspsaga outline<CR>",
        { noremap = true, desc = "[L]spsaga code [O]utline" })

      vim.api.nvim_set_keymap(
        "n",
        "<leader>lr",
        ":Lspsaga rename<CR>",
        { noremap = true, desc = "[L]spsaga [R]ename" })

    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    event = "LspAttach"
  },
}
