-- ============================================================
-- plugins/filesystem_browsing.lua  –  Neovim 0.12
-- ============================================================
-- Nota: image.nvim era commentato in 0.10 per problemi di
-- compatibilità. In 0.12 il supporto immagini è migliorato
-- ma richiede ancora luarocks + magick. Rimane commentato
-- finché non si configura l'ambiente; basta togliere i commenti
-- e aggiungere luarocks.nvim se si vuole attivarlo.
-- ============================================================

local km = require("keymaps") -- prefissi centralizzati
return {

  -- ── Remote SSH ────────────────────────────────────────────
  {
    "nosduco/remote-sshfs.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      local api = require("remote-sshfs.api")
      -- connections e builtin non servono qui:
      -- i keymap <leader>ff e <leader>fg sono in telescope.lua
      -- con integrazione remote-sshfs già inclusa.

      vim.keymap.set("n", km.remote .. "C", api.connect,    { desc = "Remote: connect" })
      vim.keymap.set("n", km.remote .. "D", api.disconnect, { desc = "Remote: disconnect" })
      vim.keymap.set("n", km.remote .. "E", api.edit,       { desc = "Remote: edit" })
      -- <leader>ff e <leader>fg sono definiti in telescope.lua
      -- con integrazione remote-sshfs già inclusa.

      require("remote-sshfs").callback.on_connect_success:add(function(host, mount_dir)
        vim.notify("Mounted " .. host .. " at " .. mount_dir)
      end)
    end,
  },

  -- ── bdelete / bwipe migliorati ────────────────────────────
  "Asheq/close-buffers.vim",

  -- ── File remoti SSH/Docker ────────────────────────────────
  {
    "miversen33/netman.nvim",
    config = function() require("netman") end,
  },

  -- ── Neo-tree: file browser ────────────────────────────────
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
      -- "3rd/image.nvim",  -- decommentare dopo aver configurato luarocks+magick
    },
    config = function()
      require("neo-tree").setup({
        update_focused_file = { enable = true },
      })
      vim.keymap.set("n", km.find .. " ",
        "<CMD>Neotree filesystem reveal left<CR>",
        { desc = "Neotree: open" })
    end,
  },

  -- ── Oil: navigazione directory come buffer ────────────────
  -- NOTA: default_file_explorer = true disabilita netrw.
  -- Questo impedisce il download automatico dei file di spell.
  -- Se serve scaricare spellfile, commentare temporaneamente
  -- oppure usare :e scp://... manualmente.
  {
    "stevearc/oil.nvim",
    config = function()
      require("oil").setup({
        default_file_explorer = true,
        win_options = { signcolumn = "yes" },
        columns = { "icon", "permissions", "size" },
        keymaps = {
          ["?"]            = "actions.show_help",
          ["<CR>"]         = "actions.select",
          [km.oil .. "v"]   = "actions.select_vsplit",
          [km.oil .. "s"]   = "actions.select_split",
          [km.oil .. "t"]   = "actions.select_tab",
          [km.oil .. "c"]   = "actions.close",
          [km.oil .. "p"]   = "actions.preview",
          ["<PageUp>"]     = "actions.preview_scroll_up",
          ["<PageDown>"]   = "actions.preview_scroll_down",
          ["-"]            = "actions.parent",
          ["`"]            = "actions.cd",
          ["~"]            = "actions.tcd",
          ["|"]            = "actions.change_sort",
          ["."]            = "actions.toggle_hidden",
          ["\\"]           = "actions.toggle_trash",
          [km.oil .. "y"]   = "actions.copy_entry_path",
          [km.oil .. "q"]   = "actions.add_to_qflist",
          [km.oil .. "l"]   = "actions.add_to_loclist",
          [km.oil .. "ow"]  = "actions.open_cwd",
          [km.oil .. "oe"]  = "actions.open_external",
          [km.oil .. "oc"]  = "actions.open_cmdline",
          [km.oil .. "od"]  = "actions.open_cmdline_dir",
          [km.oil .. "ot"]  = "actions.open_terminal",
        },
      })
      vim.keymap.set("n", "<leader> ",
        "<CMD>Oil<CR>",
        { desc = "Oil: open parent dir" })
    end,
  },

  -- ── oil-git-status: stato git in Oil ─────────────────────
  {
    "refractalize/oil-git-status.nvim",
    dependencies = { "stevearc/oil.nvim" },
    config = true,
  },

}
