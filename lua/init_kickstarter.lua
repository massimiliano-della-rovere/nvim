--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================

Kickstart.nvim is *not* a distribution.

Kickstart.nvim is a template for your own configuration.
  The goal is that you can read every line of code, top-to-bottom, understand
  what your configuration is doing, and modify it to suit your needs.

  Once you've done that, you should start exploring, configuring and tinkering to
  explore Neovim!

  If you don't know anything about Lua, I recommend taking some time to read through
  a guide. One possible example:
  - https://learnxinyminutes.com/docs/lua/


  And then you can explore or search through `:help lua-guide`
  - https://neovim.io/doc/user/lua-guide.html


Kickstart Guide:

I have left several `:help X` comments throughout the init.lua
You should run that command and read that help section for more information.

In addition, I have some `NOTE:` items throughout the file.
These are for you, the reader to help understand what is happening. Feel free to delete
them once you know what you're doing, but they should serve as a guide for when you
are first encountering a few different constructs in your nvim config.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now :)
--]]

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "


function install_lazy_if_missing()
  --    https://github.com/folke/lazy.nvim
  --    `:help lazy.nvim.txt` for more info
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable", -- latest stable release
      lazypath,
    }
  end
  vim.opt.runtimepath:prepend(lazypath)
end

-- [[ Install `lazy.nvim` plugin manager ]]
install_lazy_if_missing()

-- [[ Configure plugins ]]
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require("lazy").setup({
  -- startup screen
  {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("alpha").setup(require("alpha.themes.startify").config)
    end
  },

  -- search and replace
  {
    "nvim-pack/nvim-spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { is_block_ui_break = true },
  },

  -- NOTE: First, some plugins that don't require any configuration
  "nvim-web-devicons",
  "telescope-fzf-native",
  "nvim-treesitter/nvim-treesitter",
  "nvim-treesitter/nvim-treesitter-textobjects",

  -- pomodoro timer
  {
    "epwalsh/pomo.nvim",
    version = "*",  -- Recommended, use latest release instead of latest commit
    lazy = true,
    cmd = { "TimerStart", "TimerStop", "TimerRepeat" },
    dependencies = {
      -- Optional, but highly recommended if you want to use the "Default" timer
      "rcarriga/nvim-notify",
    },
    opts = {
      -- See below for full list of options 👇
    },
  },

  -- :cmd popup
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup({
        lsp = {
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        -- you can enable a preset for easier configuration
        presets = {
          bottom_search = true, -- use a classic bottom cmdline for search
          command_palette = true, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = false, -- add a border to hover docs and signature help
        },
      })
    end
  },

  -- Window resize
  {
    "anuvyklack/windows.nvim",
    dependencies = {
      "anuvyklack/middleclass",
      "anuvyklack/animation.nvim"
    },
    config = function()
      vim.opt.winwidth = 10
      vim.opt.winminwidth = 10
      vim.opt.equalalways = false

      require("windows").setup()

      vim.keymap.set("n", "<C-w>z", ":WindowsMaximize<CR>")
      vim.keymap.set("n", "<C-w>_", ":WindowsMaximizeVertically<CR>")
      vim.keymap.set("n", "<C-w>|", ":WindowsMaximizeHorizontally<CR>")
      vim.keymap.set("n", "<C-w>=", ":WindowsEqualize<CR>")
    end
  },

  -- navigation shortcuts
  "tpope/vim-unimpaired",

  -- improved search, add, delete, swap using regex
  "tpope/vim-abolish",

  -- git integration
  "tpope/vim-fugitive",
  -- git :GBrowse
  "tpope/vim-rhubarb",
  -- git operation symbols on the symbol bar
  "airblade/vim-gitgutter",
  -- git blame
  { "f-person/git-blame.nvim", event = "VeryLazy" },

  -- Detect tabstop and shiftwidth automatically
  "tpope/vim-sleuth",

  -- tmux integration
  "christoomey/vim-tmux-navigator",

  -- quickfix list enhancements
  {
    "kevinhwang91/nvim-bqf",
    event = "VeryLazy",
    opts = {},
  },

  -- improved folding ufo = (yo)u fo(ld)
  -- {
  --   'kevinhwang91/nvim-ufo',
  --   dependencies = { 'kevinhwang91/promise-async' },
  --   config = function()
  --     local ufo = require('ufo')
  --
  --     ufo.setup({
  --       provider_selector = function(bufnr, filetype, buftype)
  --         return {'treesitter', 'indent'}
  --       end
  --     })
  --
  --     -- vim.o.foldenable = true
  --     -- vim.o.foldcolumn = '1' -- '0' is not bad
  --     -- vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
  --     -- vim.o.foldlevelstart = 99
  --     -- vim.o.foldenable = true
  --
  --     -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
  --     vim.keymap.set(
  --       'n', 'zR',
  --       ufo.openAllFolds,
  --       { noremap = true, desc = 'Open all folds' })
  --     vim.keymap.set(
  --       'n', 'zM',
  --       ufo.closeAllFolds,
  --       { noremap = true, desc = 'Open all folds' })
  --     vim.keymap.set(
  --       'n', 'zK',
  --       function()
  --         local winid = ufo.peekFoldedLinesUnderCursor()
  --         if not winid then
  --           vim.lsp.buf.hover()
  --         end
  --       end,
  --       { noremap = true, desc = 'Peek fold' })
  --   end
  -- },

  -- comment/uncomment code
  {
    'terrortylor/nvim-comment',
    config = function()
      require('nvim_comment').setup()
    end
  },

  -- "gc"/"gb" to comment visual regions/lines
  -- { 'numToStr/Comment.nvim', opts = {} },

  -- entire file text object ae/ie
  {
    "chrisgrieser/nvim-various-textobjs",
    lazy = true,
  },

  -- surrounding tokens ('"<> etc)
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        keymaps = {
          insert = "<C-g>Sa", -- add{symbol} Add a surrounding pair around the cursor (insert mode)
          insert_line = "<C-g>SA", -- add{symbol} Add a surrounding pair around the cursor, on new lines (insert mode)

          normal = "<leader>Sa", -- add{motion}{symbol} Add a surrounding pair around a motion (normal mode)
          normal_cur = "<leader>Sl", -- add{symbol} Add a surrounding pair around the current line (normal mode)
          normal_line = "<leader>SA", -- add{motion}{symbol} Add a surrounding pair around a motion, on new lines (normal mode)
          normal_cur_line = "<leader>SL", -- add{symbol} Add a surrounding pair around the current line, on new lines (normal mode)

          visual_line = "<leader>Sl", -- add{symbol} Add a surrounding pair around a visual selection
          visual = "<leader>SL", -- add{symbol} Add a surrounding pair around a visual selection, on new lines

          delete = "<leader>Sd", -- delete{symbol} Delete a surrounding pair

          change = "<leader>Sc", -- change{old_symbol}{new_symbol} Change a surrounding pair
          change_line = "<leader>SC", -- change{old_symbol}{new_symbol} Change a surrounding pair, putting replacements on new lines
        }
      })
    end
  },

  -- marks in the left column
  {
    "chentoast/marks.nvim",
    config = function()
      require("marks").setup()
    end
  },

  -- ctags generation
  {
    "ludovicchabant/vim-gutentags",
    config = function()
      vim.g.gutentags_project_root = {
        ".git",
        "package.json",
        "LICENSE",
        "README.md"
      }
      vim.g.gutentags_ctags_tagfile = "tags"
      vim.g.gutentags_cache_dir = vim.fn.expand("~/.cache/vim/ctags/")
      vim.api.nvim_create_user_command(
        "GutentagsClearCache",
        vim.fn.system("rm " .. vim.g.gutentags_cache_dir .. "/*"),
        { desc = "Clear Gutentags cache in " .. vim.g.gutentags_cache_dir }
      )
      vim.g.gutentags_generate_on_new = 1
      vim.g.gutentags_generate_on_missing = 1
      vim.g.gutentags_generate_on_write = 1
      vim.g.gutentags_generate_on_empty_buffer = 0
      vim.g.gutentags_ctags_extra_args = { "--tag-relative=yes", "--fields=+ailmnS" }
      vim.g.gutentags_ctags_exclude = {
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
    end
  },

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { "williamboman/mason.nvim", config = true },
      "williamboman/mason-lspconfig.nvim",

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require("fidget").setup({})`
      { "j-hui/fidget.nvim", opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      "folke/neodev.nvim",
    },
  },

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

  -- Useful plugin to show you pending keybinds.
  { "folke/which-key.nvim", opts = {} },

  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    "lewis6991/gitsigns.nvim",
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        -- vim.keymap.set(
        --   "n", "<leader>hp",
        --   require("gitsigns").preview_hunk,
        --   { buffer = bufnr, desc = "Git: [H]unk [P]review" })
        -- vim.keymap.set(
        --   "n", "<leader>hs",
        --   ":GitGutterStageHunk",
        --   { buffer = bufnr, desc = "Git: [H]unk [S]tage" })
        -- vim.keymap.set(
        --   "n", "<leader>hu",
        --   ":GitGutterUndoHunk",
        --   { buffer = bufnr, desc = "Git: [H]unk [U]ndo" })

        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        vim.keymap.set(
          { "n", "v" }, "]c",
          function()
            if vim.wo.diff then
              return "]c"
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return "<Ignore>"
          end,
          { expr = true, buffer = bufnr, desc = "Git: to next [C]hange" })
        vim.keymap.set(
          { "n", "v" }, "[c",
          function()
            if vim.wo.diff then
              return "[c"
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return "<Ignore>"
          end,
          { expr = true, buffer = bufnr, desc = "Git: to prev [C]hange" })

        -- Actions
        -- visual mode
        map('v', '<leader>hs', function()
          gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'stage git hunk' })
        map('v', '<leader>hr', function()
          gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'reset git hunk' })
        -- normal mode
        map('n', '<leader>hs', gs.stage_hunk, { desc = 'git stage hunk' })
        map('n', '<leader>hr', gs.reset_hunk, { desc = 'git reset hunk' })
        map('n', '<leader>hS', gs.stage_buffer, { desc = 'git Stage buffer' })
        map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
        map('n', '<leader>hR', gs.reset_buffer, { desc = 'git Reset buffer' })
        map('n', '<leader>hp', gs.preview_hunk, { desc = 'preview git hunk' })
        map('n', '<leader>hb', function()
          gs.blame_line { full = false }
        end, { desc = 'git blame line' })
        map('n', '<leader>hd', gs.diffthis, { desc = 'git diff against index' })
        map('n', '<leader>hD', function()
          gs.diffthis '~'
        end, { desc = 'git diff against last commit' })

        -- Toggles
        map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
        map('n', '<leader>td', gs.toggle_deleted, { desc = 'toggle git show deleted' })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
      end,
    },
  },

  -- Colorscheme
  -- { 
  --   "catppuccin/nvim",
  --   config = function()
  --     vim.cmd.colorscheme("catppuccin")
  --   end,
  -- },
  {
    "rebelot/kanagawa.nvim",
    opts = { dimInactive = true },
    config = function()
      vim.cmd.colorscheme("kanagawa-wave") -- kanagawa-dragon, kanagawa-lotus
    end,
  },
  -- {
  --   "knghtbrd/tigrana",
  --   priority = 2000,
  --   config = function()
  --     vim.cmd.colorscheme("tigrana-256-dark")
  --   end
  -- },
  -- {
  --   -- Theme inspired by Atom
  --   "navarasu/onedark.nvim",
  --   priority = 1000,
  --   config = function()
  --     vim.cmd.colorscheme("onedark")
  --   end,
  -- },

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

  {
    "Wansmer/treesj",
    -- keys = { "<space>m", "<space>j", "<space>s" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    cmd = { "TSJToggle", "TSJSplit", "TSJJoin" },
    config = function()
      local tsj = require("treesj")

      tsj.setup({ use_default_keymaps = false })

      -- For use default preset and it work with dot
      vim.keymap.set(
        "n", "<leader>tj",
        tsj.join,
        { desc = "[T]ree split/[J]oin", noremap = true } )
      -- For use default preset and it work with dot
      vim.keymap.set(
        "n", "<leader>ts",
        tsj.split,
        { desc = "[T]ree [S]plit/join", noremap = true } )
      -- For use default preset and it work with dot
      vim.keymap.set(
        "n", "<leader>tm",
        tsj.toggle,
        { desc = "[T]ree split/join shallow [T]oggle", noremap = true } )
      -- For extending default preset with `recursive = true`, but this doesn"t work with dot
      vim.keymap.set(
        "n", "<leader>tM",
        function()
          tsj.toggle({ split = { recursive = true } })
        end,
        { desc = "[T]ree split/join recursive [T]oggle", noremap = true } )
    end,
  },

  -- rainbow matching delimiter symbols
  {
    "HiPhish/rainbow-delimiters.nvim",
    config = function()
      -- This module contains a number of default definitions
      local rainbow_delimiters = require "rainbow-delimiters"

      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
          vim = rainbow_delimiters.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
        },
        priority = {
          [""] = 110,
          lua = 210,
        },
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
    end
  },

  -- highlight vertical indent lines
  {
    -- Add indentation guides even on blank lines
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      local highlight = {
        "RainbowRed",
        "RainbowYellow",
        "RainbowBlue",
        "RainbowOrange",
        "RainbowGreen",
        "RainbowViolet",
        "RainbowCyan",
      }
      local hooks = require("ibl.hooks")
      -- create the highlight groups in the highlight setup hook, so they are reset
      -- every time the colorscheme changes
      hooks.register(
        hooks.type.HIGHLIGHT_SETUP,
        function()
          vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
          vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
          vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
          vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
          vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
          vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
          vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
        end
      )
      vim.g.rainbow_delimiters = { highlight = highlight }
      require("ibl").setup({ scope = { highlight = highlight } })
      hooks.register(
        hooks.type.SCOPE_HIGHLIGHT,
        hooks.builtin.scope_highlight_from_extmark)
    end
  },

  {
    -- Set lualine as statusline
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = true,
        -- theme = "onedark",
        -- component_separators = { left = "", right = ""}, -- = "|",
        -- section_separators = { left = "", right = ""}, -- = "",
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" }
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 3 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress", "filesize", "searchcount" },
        lualine_z = { "location", "selectioncount"  },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {}
      },
      tabline = {
        lualine_a = { "'b'", { "buffers", mode = 4, use_mode_colors = true } },
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "'w'", { "windows", mode = 2, use_mode_colors = true } },
        lualine_y = { "'t'", { "tabs", mode = 2, use_mode_colors = true } },
        lualine_z = { "hostname", { "datetime", style = "%Y-%m-%d %H:%M:%S" } },
      },
      -- winbar = {
      --   lualine_a = { { "windows", mode = 2 } },
      --   lualine_b = {},
      --   lualine_c = {},
      --   lualine_x = { "searchcount" },
      --   lualine_y = {},
      --   lualine_z = { "selectioncount" },
      -- },
      -- inactive_winbar = {
      --   lualine_a = { { "windows", mode = 0 } },
      --   lualine_b = {},
      --   lualine_c = {},
      --   lualine_x = {},
      --   lualine_y = {},
      --   lualine_z = {},
      -- }
    },
  },

  {
    -- Add indentation guides even on blank lines
    "lukas-reineke/indent-blankline.nvim",
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = "ibl",
    opts = {},
  },

  -- Fuzzy Finder (files, lsp, etc)
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "BurntSushi/ripgrep",
      "sharkdp/fd",
      "nvim-treesitter/nvim-treesitter",
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = "make",
        cond = function()
          return vim.fn.executable "make" == 1
        end,
      },
    },
  },

  {
    -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    build = ":TSUpdate",
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
  -- {
  --   "Bekaboo/dropbar.nvim",
  --   -- optional, but required for fuzzy finder support
  --   dependencies = {
  --     "nvim-telescope/telescope-fzf-native.nvim",
  --     "nvim-tree/nvim-web-devicons"
  --   }
  -- },
  -- -- symbol tree
  -- {
  --   "simrat39/symbols-outline.nvim",
  --   config = function()
  --     require("symbols-outline").setup()
  --   end
  -- },

  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I"ve included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require "kickstart.plugins.autoformat",
  -- require "kickstart.plugins.debug",

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you"re interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  -- { import = "custom.plugins" },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    config = function()
      local fb_actions = require "telescope._extensions.file_browser.actions"

      require("telescope").setup({
        extensions = {
          file_browser = {
            path = vim.loop.cwd(),
            cwd = vim.loop.cwd(),
            cwd_to_path = false,
            grouped = false,
            files = true,
            add_dirs = true,
            depth = 1,
            auto_depth = false,
            select_buffer = false,
            hidden = { file_browser = false, folder_browser = false },
            respect_gitignore = vim.fn.executable "fd" == 1,
            no_ignore = false,
            follow_symlinks = false,
            browse_files = require("telescope._extensions.file_browser.finders").browse_files,
            browse_folders = require("telescope._extensions.file_browser.finders").browse_folders,
            hide_parent_dir = false,
            collapse_dirs = false,
            prompt_path = false,
            quiet = false,
            dir_icon = "",
            dir_icon_hl = "Default",
            display_stat = { date = true, size = true, mode = true },
            hijack_netrw = false,
            use_fd = true,
            git_status = true,
            mappings = {
              ["i"] = {
                ["<A-c>"] = fb_actions.create,
                ["<S-CR>"] = fb_actions.create_from_prompt,
                ["<A-r>"] = fb_actions.rename,
                ["<A-m>"] = fb_actions.move,
                ["<A-y>"] = fb_actions.copy,
                ["<A-d>"] = fb_actions.remove,
                ["<C-o>"] = fb_actions.open,
                ["<C-g>"] = fb_actions.goto_parent_dir,
                ["<C-e>"] = fb_actions.goto_home_dir,
                ["<C-w>"] = fb_actions.goto_cwd,
                ["<C-t>"] = fb_actions.change_cwd,
                ["<C-f>"] = fb_actions.toggle_browser,
                ["<C-h>"] = fb_actions.toggle_hidden,
                ["<C-s>"] = fb_actions.toggle_all,
                ["<bs>"] = fb_actions.backspace,
              },
              ["n"] = {
                ["c"] = fb_actions.create,
                ["r"] = fb_actions.rename,
                ["m"] = fb_actions.move,
                ["y"] = fb_actions.copy,
                ["d"] = fb_actions.remove,
                ["o"] = fb_actions.open,
                ["g"] = fb_actions.goto_parent_dir,
                ["e"] = fb_actions.goto_home_dir,
                ["w"] = fb_actions.goto_cwd,
                ["t"] = fb_actions.change_cwd,
                ["f"] = fb_actions.toggle_browser,
                ["h"] = fb_actions.toggle_hidden,
                ["s"] = fb_actions.toggle_all,
              },
            },
          },
        },
      })

      require("telescope").load_extension("file_browser")

      vim.api.nvim_set_keymap(
        "n",
        "<space>fb",
        ":Telescope file_browser<CR>",
        { noremap = true, desc = "[F]ile [B]rowser" })
    end
  },

  -- filesystem as a buffer
  {
    "stevearc/oil.nvim",
    opts = {},
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("oil").setup()
      vim.keymap.set("n", "-", ":Oil<CR>", { desc = "Open parent directory" })
    end
  },

   -- DB
  {
    "kristijanhusak/vim-dadbod-ui",
    build = ":TSInstall sqlls",  -- :TSInstall sqlls
    dependencies = {
      {
        "tpope/vim-dadbod",
        lazy = true,
        config = function()
          -- vim.g.db_ui_save_location = vim.fn.stdpath("config" .. require("plenary.path").path.sep .. "db_ui")
        end
      },
      {
        "kristijanhusak/vim-dadbod-completion",
        ft = { "sql", "mysql", "plsql" },
        lazy = true,
        config = function()
          vim.api.nvim_create_autocmd(
            "FileType",
            { pattern = { "sql", },
              command = [[setlocal omnifunc=vim_dadbod_completion#omni]],
            })

          local function db_completion()
            require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
          end

          local autocomplete_group = vim.api.nvim_create_augroup("vimrc_autocompletion", { clear = true })
          vim.api.nvim_create_autocmd(
            "FileType",
            {
              pattern = { "sql", "mysql", "plsql" },
              group = autocomplete_group,
              callback = function()
                -- vim.schedule(db_completion)
                require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
              end,
            }
          )
        end
      },
    },
    cmd = {
      "DBUI",
      "DBUIToggle",
      "DBUIAddConnection",
      "DBUIFindBuffer",
    },
    build = ":TSInstall sql",
    init = function()
      -- Your DBUI configuration
      vim.g.db_ui_use_nerd_fonts = 1

      vim.api.nvim_set_keymap(
        "n",
        "<leader>Da",
        ":DBUIAddConnection<CR>",
        { noremap = true, desc = "[D]B [A]dd connection" })

      vim.api.nvim_set_keymap(
        "n",
        "<leader>Du",
        ":DBUIToggle<CR>",
        { noremap = true, desc = "[D]B toggle [U]I" })

      vim.api.nvim_set_keymap(
        "n",
        "<leader>Df",
        ":DBUIFindBuffer<CR>",
        { noremap = true, desc = "[D]B [F]ind buffer" })

      vim.api.nvim_set_keymap(
        "n",
        "<leader>Dr",
        ":DBUIRenameBuffer<CR>",
        { noremap = true, desc = "[D]B [R]ename buffer" })

      vim.api.nvim_set_keymap(
        "n",
        "<leader>Dq",
        ":DBUILastQueryInfo<CR>",
        { noremap = true, desc = "[D]B last [Q]uery info" })
    end,
  },

  -- debug

}, {})

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

vim.opt.path:append("**")

-- Preview changes in smaller window
vim.opt.inccommand = "split"

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 999

-- Virtual edit in visual "block" mode
vim.opt.virtualedit = "block"

-- Crosshair on current character
vim.opt.cursorcolumn = true
vim.opt.cursorline = true

-- Set highlight on search
vim.opt.hlsearch = true

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = true

-- Enable mouse mode
vim.opt.mouse = "a"

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.clipboard = "unnamedplus"

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- search wraps at top from bottom
vim.opt.wrapscan = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.opt.completeopt = 'menuone,noselect,noinsert'

-- NOTE: You should make sure your terminal supports this
vim.opt.termguicolors = true

-- new split windows
vim.opt.splitbelow = true
vim.opt.splitright = true

-- c-a and c-x target
vim.opt.nrformats = { "bin", "octal", "hex" }

-- char symbols
vim.opt.listchars = {
  eol = "¶",
  tab = "‹·›",
  trail = "·",
  extends = "›",
  precedes = "‹",
  nbsp = "•",
  conceal = "×"}
vim.opt.showbreak = "⮎" -- ⤷ +++

-- folding
-- vim.opt.foldmethod = 'syntax'
-- vim.opt.foldenable = true
vim.opt.foldlevel = 0
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldminlines = 5
vim.opt.foldnestmax = 10
if not vim.startswith(vim.g.colors_name, "kanagawa") then
  vim.api.nvim_set_hl(0, "Folded", { bg = "#403000", fg = "#FF40FF" })
end

-- spell languages
vim.opt.spell = false
vim.opt.spelllang = { "en_us", "it", "eo" }

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- make Y do what is expected to do
vim.keymap.set("n", "Y", "y$", { desc = "Copy line from the cursor position till the end" })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd(
  "TextYankPost",
  {
    callback = function()
      vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = "*",
  })

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require("telescope").setup {
  defaults = {
    mappings = {
      i = {
        ["<C-u>"] = false,
        ["<C-d>"] = false,
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require("telescope").load_extension, "fzf")

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer"s path
local function find_git_root()
  -- Use the current buffer"s path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == "" then
    current_dir = cwd
  else
    -- Extract the directory from the current file"s path
    current_dir = vim.fn.fnamemodify(current_file, ":h")
  end

  -- Find the Git root directory from the current file"s path
  local git_root = vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    print("Not a git repository. Searching on current working directory")
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require("telescope.builtin").live_grep({
      search_dirs = {git_root},
    })
  end
end

vim.api.nvim_create_user_command("LiveGrepGitRoot", live_grep_git_root, {})

-- See `:help telescope.builtin`
vim.keymap.set("n", "<leader>?", require("telescope.builtin").oldfiles, { desc = "[?] Find recently opened files" })
vim.keymap.set("n", "<leader><space>", require("telescope.builtin").buffers, { desc = "[ ] Find existing buffers" })
vim.keymap.set("n", "<leader>/", function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = "[/] Fuzzily search in current buffer" })

vim.keymap.set("n", "<M-l>", "<CMD>bnext<CR>", { noremap = true, desc = "Next Buffer" })
vim.keymap.set("n", "<M-h>", "<CMD>bprev<CR>", { noremap = true, desc = "Prev Buffer" })
vim.keymap.set("n", "<M-k>", "<CMD>bprev<CR>", { noremap = true, desc = "Prev Buffer" })
vim.keymap.set("n", "<M-j>", "<CMD>bnext<CR>", { noremap = true, desc = "Next Buffer" })

local function telescope_live_grep_open_files()
  require('telescope.builtin').live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end
vim.keymap.set("n", "<leader>s/", telescope_live_grep_open_files, { desc = "[S]earch [/] in Open Files" })
vim.keymap.set("n", "<leader>ss", ":SymbolsOutline<cr>", { desc = "[S]earch [S]ymbols outline" })
vim.keymap.set("n", "<leader>gf", require("telescope.builtin").git_files, { desc = "Search [G]it [F]iles" })
vim.keymap.set("n", "<leader>sf", require("telescope.builtin").find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>sh", require("telescope.builtin").help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sw", require("telescope.builtin").grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sg", require("telescope.builtin").live_grep, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sG", ":LiveGrepGitRoot<cr>", { desc = "[S]earch by [G]rep on Git Root" })
vim.keymap.set("n", "<leader>sd", require("telescope.builtin").diagnostics, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>sr", require("telescope.builtin").resume, { desc = "[S]earch [R]esume" })


vim.keymap.set("n", "<c-h>", ":TmuxNavigateLeft<cr>", { desc = "Tmux Window Left" })
vim.keymap.set("n", "<c-j>", ":TmuxNavigateDown<cr>", { desc = "Tmux Window Down" })
vim.keymap.set("n", "<c-k>", ":TmuxNavigateUp<cr>", { desc = "Tmux Window Up" })
vim.keymap.set("n", "<c-l>", ":TmuxNavigateRight<cr>", { desc = "Tmux Window Right" })

vim.api.nvim_create_autocmd(
  { "BufWritePost" },
  {
    pattern = "~/.config/nvim/init.lua",
    command = "source %"
  })
vim.keymap.set("n", "<leader>ve", ":edit ~/.config/nvim/init.lua<cr>", { desc = "N[V]im [E]dit configuration" })
vim.keymap.set("n", "<leader>vs", ":source ~/.config/nvim/init.lua<cr>", { desc = "N[V]im [S]ave configuration"})


-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require("nvim-treesitter.configs").setup({
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { "c", "cpp", "go", "lua", "python", "rust", "tsx", "javascript", "typescript", "vimdoc", "vim", "bash", "sql" },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,

    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<c-space>",
        node_incremental = "<c-space>",
        scope_incremental = "<c-s>",
        node_decremental = "<M-space>",
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ["aa"] = "@parameter.outer",
          ["ia"] = "@parameter.inner",
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          ["]m"] = "@function.outer",
          ["]]"] = "@class.outer",
        },
        goto_next_end = {
          ["]M"] = "@function.outer",
          ["]["] = "@class.outer",
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[["] = "@class.outer",
        },
        goto_previous_end = {
          ["[M"] = "@function.outer",
          ["[]"] = "@class.outer",
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ["<leader>a"] = "@parameter.inner",
        },
        swap_previous = {
          ["<leader>A"] = "@parameter.inner",
        },
      },
    },
  })
end, 0)

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = "LSP: " .. desc
    end

    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
  end

  nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
  nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

  nmap("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
  nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
  nmap("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
  nmap("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
  nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
  nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

  -- See `:help K` for why this keymap
  nmap("K", vim.lsp.buf.hover, "Hover Documentation")
  nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

  -- Lesser used LSP functionality
  nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
  nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
  nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
  nmap("<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, "[W]orkspace [L]ist Folders")

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
    vim.lsp.buf.format()
  end, { desc = "Format current buffer with LSP" })
end

-- document existing key chains
require("which-key").register {
  ["<leader>c"] = { name = "[C]ode", _ = "which_key_ignore" },
  ["<leader>d"] = { name = "[D]ocument", _ = "which_key_ignore" },
  ["<leader>g"] = { name = "[G]it", _ = "which_key_ignore" },
  ["<leader>h"] = { name = "More git", _ = "which_key_ignore" },
  ["<leader>r"] = { name = "[R]ename", _ = "which_key_ignore" },
  ["<leader>s"] = { name = "[S]earch", _ = "which_key_ignore" },
  ["<leader>w"] = { name = "[W]orkspace", _ = "which_key_ignore" },
}
-- register which-key VISUAL mode
-- required for visual <leader>hs (hunk stage) to work
require("which-key").register({
  ["<leader>"] = { name = "VISUAL <leader>" },
  ["<leader>h"] = { "Git [H]unk" },
}, { mode = "v" })

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require("mason").setup()
require("mason-lspconfig").setup()

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

-- Setup neovim lua configuration
require("neodev").setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require "mason-lspconfig"

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

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
