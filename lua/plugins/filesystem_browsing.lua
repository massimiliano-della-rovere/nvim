return {
  -- this is for nvim 0.11 -- https://github.com/3rd/image.nvim?tab=readme-ov-file#plugin-installation
  -- {
  --   "vhyrro/luarocks.nvim",
  --   priority = 1001, -- this plugin needs to run before anything else
  --   opts = {
  --     rocks = { "magick" },
  --   },
  -- },
  -- {
  --   "3rd/image.nvim",
  --   opts = {}
  -- },
  -- remote/sshfs
  {
    "nosduco/remote-sshfs.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      -- Refer to the configuration section below
      -- or leave empty for defaults
      local api = require('remote-sshfs.api')
      vim.keymap.set('n', '<leader>RC', api.connect, { desc = "Remote Connect" })
      vim.keymap.set('n', '<leader>RD', api.disconnect, { desc = "Remote Disconnect" })
      vim.keymap.set('n', '<leader>RE', api.edit, { desc = "Remote Edit" })

      -- (optional) Override telescope find_files and live_grep to make dynamic based on if connected to host
      local builtin = require("telescope.builtin")
      local connections = require("remote-sshfs.connections")
      vim.keymap.set("n", "<leader>ff", function()
        if connections.is_connected() then
          api.find_files()
        else
          builtin.find_files()
        end
      end, {})
      vim.keymap.set("n", "<leader>fg", function()
        if connections.is_connected() then
          api.live_grep()
        else
          builtin.live_grep()
        end
      end, {})

      require("remote-sshfs").callback.on_connect_success:add(function(host, mount_dir)
        vim.notify("Mounted " .. host .. " at " .. mount_dir)
      end)
    end
  },

  -- enhanced bdelete and bwipe
  "Asheq/close-buffers.vim",

  -- remote ssh/docker file
  {
    -- https://github.com/miversen33/netman.nvim
    "miversen33/netman.nvim",

    config = function()
      require("netman")
    end
  },

  -- file browser
  {
    -- TODO: config
    -- https://github.com/nvim-neo-tree/neo-tree.nvim
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
      "3rd/image.nvim",
    },
    config = function()
      require("neo-tree").setup({
        update_focused_file = {
          enable = true,
        }
      })
      vim.keymap.set(
        "n", "<leader>f ",
        "<CMD>Neotree filesystem reveal left<CR>",
        { desc = "Neotree: Open filebrowser" })
    end,
  },

  -- LSP filesystem operations
  {
    "antosha417/nvim-lsp-file-operations",
    dependencies = {
      "nvim-lua/plenary.nvim",
    -- Uncomment whichever supported plugin(s) you use
    -- "nvim-tree/nvim-tree.lua",
    "nvim-neo-tree/neo-tree.nvim",
    -- "simonmclean/triptych.nvim"
    },
    config = function()
      require("lsp-file-operations").setup()

      -- this goes into mason_lsp.lua#nvim-lspconfig
      -- local lspconfig = require('lspconfig')
      --
      -- -- Set global defaults for all servers
      -- lspconfig.util.default_config = vim.tbl_extend(
      --   'force',
      --   lspconfig.util.default_config,
      --   {
      --     capabilities = vim.tbl_deep_extend(
      --       "force",
      --       vim.lsp.protocol.make_client_capabilities(),
      --       -- returns configured operations if setup() was already called
      --       -- or default operations if not
      --       require('lsp-file-operations').default_capabilities(),
      --     )
      --   }
      -- )
    end,
  },

  -- quick dir traversing
  {
    -- https://github.com/stevearc/oil.nvim
    "stevearc/oil.nvim",
    -- disabling NetRW has the side effect of making (n)vim unable to download spellfiles!
    -- if you need to download/restore your spell files, uncomment temporarily the next line,
    -- download the spell files, and comment it out again.
    -- cmd = "Oil",
    -- see dpetka2001's comment about the previous line
    -- https://www.reddit.com/r/neovim/comments/19d0we4/need_help_with_missing_download_spell_file/
    config = function()
      require("oil").setup({
        default_file_explorer = true,
        win_options = { signcolumn = "yes" },
        columns = {
          "icon", "permissions", "size",
          -- "ctime", "mtime", "atime", "birthtime"
        },
        keymaps = {
          ["?"] = "actions.show_help",

          ["<CR>"] = "actions.select",
          ["<leader>ov"] = "actions.select_vsplit",
          ["<leader>os"] = "actions.select_split",
          ["<leader>ot"] = "actions.select_tab",
          ["<leader>oc"] = "actions.close",

          ["<leader>op"] = "actions.preview",
          ["<PageUp>"] = "actions.preview_scroll_up",
          ["<PageDown>"] = "actions.preview_scroll_down",

          ["-"] = "actions.parent",
          ["<leader>gp"] = "actions.parent",
          ["`"] = "actions.cd",
          ["<leader>gc"] = "actions.cd",
          ["~"] = "actions.tcd",
          ["<leader>gt"] = "actions.tcd",

          ["|"] = "actions.change_sort",
          ["<leader>ocs"] = "actions.change_sort",

          ["<leader>oow"] = "actions.open_cwd",
          ["<leader>ooe"] = "actions.open_external",
          ["<leader>ooc"] = "actions.open_cmdline",
          ["<leader>ood"] = "actions.open_cmdline_dir",
          ["<leader>oot"] = "actions.open_terminal",

          ["."] = "actions.toggle_hidden",
          ["<leader>oth"] = "actions.toggle_hidden",
          ["\\"] = "actions.toggle_trash",
          ["<leader>ott"] = "actions.toggle_trash",
          ["<leader>or"] = "action.refresh",

          ["<leader>oy"] = "actions.copy_entry_path",
          ["<leader>oq"] = "actions.add_to_qflist",
          ["<leader>ol"] = "actions.add_to_loclist",
        },
      })
      vim.keymap.set(
        "n", "<leader> ",
        "<CMD>Oil<CR>",
        { desc = "Open parent directory" })
    end
  },

  -- git integration for oil
  {
    -- https://github.com/refractalize/oil-git-status.nvim
    "refractalize/oil-git-status.nvim",

    dependencies = {
      "stevearc/oil.nvim",
    },

    config = true,
  },

}
