local km = require("keymaps") -- prefissi centralizzati
return {
  -- entire file text object gG
  {
    -- https://github.com/chrisgrieser/nvim-various-textobjs
    "chrisgrieser/nvim-various-textobjs",
    lazy = true,
  },

  -- surrounding tokens ('"<> etc)
  {
    -- https://github.com/kylechui/nvim-surround
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      vim.g.nvim_surround_no_normal_mappings = true
      require("nvim-surround").setup({})
      vim.keymap.set("i", "<C-g>Sa", "<Plug>(nvim-surround-insert)", {
        desc = "Add a surrounding pair around the cursor (insert mode)",
      })
      vim.keymap.set("i", "<C-g>SA", "<Plug>(nvim-surround-insert-line)", {
        desc = "Add a surrounding pair around the cursor, on new lines (insert mode)",
      })

      vim.keymap.set("n", km.surround .. "a", "<Plug>(nvim-surround-normal)", {
        desc = "Add a surrounding pair around a motion (normal mode)",
      })
      vim.keymap.set("n", km.surround .. "l", "<Plug>(nvim-surround-normal-cur)", {
        desc = "Add a surrounding pair around the current line (normal mode)",
      })
      vim.keymap.set("n", km.surround .. "A", "<Plug>(nvim-surround-normal-line)", {
        desc = "Add a surrounding pair around a motion, on new lines (normal mode)",
      })
      vim.keymap.set("n", km.surround .. "L", "<Plug>(nvim-surround-normal-cur-line)", {
        desc = "Add a surrounding pair around the current line, on new lines (normal mode)",
      })

      vim.keymap.set("x", km.surround .. "l", "<Plug>(nvim-surround-visual)", {
        desc = "Add a surrounding pair around a visual selection",
      })
      vim.keymap.set("x", km.surround .. "L", "<Plug>(nvim-surround-visual-line)", {
        desc = "Add a surrounding pair around a visual selection, on new lines",
      })

      vim.keymap.set("n", km.surround .. "d", "<Plug>(nvim-surround-delete)", {
        desc = "Delete a surrounding pair",
      })

      vim.keymap.set("n", km.surround .. "c", "<Plug>(nvim-surround-change)", {
        desc = "Change a surrounding pair",
      })
      vim.keymap.set("n", km.surround .. "C", "<Plug>(nvim-surround-change-line)", {
        desc = "Change a surrounding pair, putting replacements on new lines",
      })
    end
  },

  -- Split/Join tree-like structures
  {
    -- https://github.com/Wansmer/treesj
    "Wansmer/treesj",
    -- keys = { "<space>m", "<space>j", "<space>s" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    cmd = { "TSJToggle", "TSJSplit", "TSJJoin" },
    config = function()
      local tsj = require("treesj")

      tsj.setup({ use_default_keymaps = false })

      -- For use default preset and it work with dot
      vim.keymap.set(
        "n", km.treesj .. "j",
        tsj.join,
        { desc = "TreeSJ: Join", noremap = true } )
      -- For use default preset and it work with dot
      vim.keymap.set(
        "n", km.treesj .. "s",
        tsj.split,
        { desc = "TreeSJ: Split", noremap = true } )
      -- For use default preset and it work with dot
      vim.keymap.set(
        "n", km.treesj .. "m",
        tsj.toggle,
        { desc = "TreeSJ: shallow Toggle", noremap = true } )
      -- For extending default preset with `recursive = true`, but this doesn"t work with dot
      vim.keymap.set(
        "n", km.treesj .. "M",
        function()
          tsj.toggle({ split = { recursive = true } })
        end,
        { desc = "TreeSJ: recursive Toggle", noremap = true } )
    end,
  },

  -- ============================================================
  -- windwp/nvim-autopairs
  -- ============================================================
  -- Chiude automaticamente (, [, {, ", ', ` mentre scrivi.
  -- Usa Treesitter per essere "smart": non chiude dentro stringhe
  -- o commenti quando non ha senso.
  --
  -- Integrazione con nvim-cmp: quando cmp conferma un item che
  -- termina con ( (es. una funzione), autopairs inserisce ) e
  -- posiziona il cursore dentro le parentesi.
  --
  -- <M-e>: fast wrap — avvolge la parola sotto cursore nelle
  --         parentesi desiderate senza spostare il cursore.
  -- ============================================================
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = { "hrsh7th/nvim-cmp" },
    config = function()
      local autopairs = require("nvim-autopairs")

      autopairs.setup({
        check_ts          = true,   -- usa treesitter per decisioni smarter
        ts_config = {
          lua        = { "string", "source" },
          javascript = { "string", "template_string" },
          python     = { "string" },
        },
        disable_filetype     = { "TelescopePrompt", "spectre_panel", "vim" },
        disable_in_macro     = true,
        disable_in_visualblock = false,
        ignored_next_char    = [=[[%w%%%'%[%"%.%`%$]]=],
        enable_moveright     = true,
        enable_afterquote    = true,
        enable_check_bracket_line = true,
        enable_bracket_in_quote = true,
        enable_abbr          = false,

        -- Fast wrap: <M-e> avvolge la parola corrente
        fast_wrap = {
          map            = "<M-e>",
          chars          = { "{", "[", "(", '"', "'" },
          pattern        = [=[[%'%"%>%]%)%}%,]]=],
          end_key        = "$",
          before_key     = "h",
          after_key      = "l",
          cursor_pos_before = true,
          keys           = "qwertyuiopzxcvbnmasdfghjkl",
          manual_position = true,
          highlight      = "Search",
          highlight_grey = "Comment",
        },
      })

      -- Integrazione con nvim-cmp: inserisce ) automaticamente
      -- dopo aver confermato una funzione dal menu di completamento
      local cmp_ok, cmp = pcall(require, "cmp")
      if cmp_ok then
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end
    end,
  },
}
