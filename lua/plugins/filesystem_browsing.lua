return {
  -- enhanced bdelete and bwipe
  "Asheq/close-buffers.vim",

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
      vim.keymap.set(
        "n", "<leader>f ",
        "<CMD>Neotree filesystem reveal left<CR>",
        { desc = "Neotree: Open filebrowser" })
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
