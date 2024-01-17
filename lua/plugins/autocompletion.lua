return {

  -- autocompletion, suggestion and snippets while typing
  {
    -- https://github.com/hrsh7th/nvim-cmp
    "hrsh7th/nvim-cmp", -- the autocompletion plugin
    dependencies = {
      -- completion source
      "neovim/nvim-lspconfig", -- lsp configuration
      "hrsh7th/cmp-nvim-lsp", -- lsp completion
      "hrsh7th/cmp-buffer", -- buffer completion
      "hrsh7th/cmp-path", -- path/filesystem completion
      "hrsh7th/cmp-cmdline", -- command line completion
      "hrsh7th/cmp-git", -- git files and data completion
      "saadparwaiz1/cmp_luasnip", -- snippet completion
      "rafamadriz/friendly-snippets", -- VSCode-like snippets
      -- snippet completion engine
      {
        -- https://github.com/L3MON4D3/LuaSnip
        "L3MON4D3/LuaSnip",
        version = "v2.*", -- is this necessary?
        build = "make install_jsrgexp", -- is this necessary?
      },
      "onsails/lspkind.nvim", -- icons in completion items
    },
    config = function()
      local cmp = require("cmp")
      local lspkind = require("lspkind")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()
      luasnip.config.setup({})

      local function check_backspace()
        local col = vim.fn.col(".") - 1
        return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
      end

      cmp.setup({
        preselect = cmp.PreselectMode.None,
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text",
            menu = ({
              rg = "[Rg]",
              buffer = "[Buffer]",
              nvim_lsp = "[LSP]",
              luasnip = "[Snippet]",
              -- vsnip = "[Snippet]",
              tags = "[Tag]",
              path = "[Path]",
              orgmode = "[Org]",
              git = "[Git]",
              nvim_lua = "[LUA]",
              latex_symbols = "[Latex]",
              ["vim-dadbod-completion"] = "[DB]",
            })
          })
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        completion = {
          completeopt = "menu,menuone,noinsert,noselect"
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        -- https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/config/mapping.lua
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete({}),
          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expandable() then
              luasnip.expand()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              cmp.complete()
              -- fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            elseif check_backspace() then
              fallback()
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources(
          {
            { name = "nvim_lsp" },
            { name = "luasnip" },
            { name = "buffer" },
            { name = "tags", keyword_length = 2 },
            { name = "rg", keyword_length = 3 },
            { name = "path" },
            { name = "orgmode" },
          })
      })

      -- Set configuration for specific filetype.
      cmp.setup.filetype(
        "gitcommit", {
          sources = cmp.config.sources({
            { name = "git" },
          }, {
            { name = "buffer" },
          })
      })

      -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won"t work anymore).
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" }
        }
      })

      -- Use cmdline & path source for ":" (if you enabled `native_menu`, this won"t work anymore).
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" }
        }, {
            { name = "cmdline" }
          })
      })

      -- items highlighted by type
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

    end,
  },

}
