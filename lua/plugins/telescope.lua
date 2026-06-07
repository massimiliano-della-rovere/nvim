-- ============================================================
-- plugins/telescope.lua  --  Neovim 0.12
-- ============================================================
-- RICERCA CON ARGOMENTI rg  (<leader>fg)
--
-- Nel prompt scrivi il pattern seguito da qualsiasi flag rg:
--   TODO                           ricerca normale
--   TODO --glob "*.py"             solo file Python
--   TODO --type lua                solo Lua  (vedi: rg --type-list)
--   TODO --iglob "!*.test.*"       escludi test
--   TODO src/lib/                  limita a una sottodirectory
--   "my phrase" -F                 stringa letterale (no regex)
--   error -s                       case-sensitive
--   error -i                       case-insensitive
--   TODO -w                        solo parole intere
--
-- SCORCIATOIE nel prompt (insert mode):
--
--   <C-o>      mette il pattern tra virgolette
--   <M-g>      aggiunge " --glob "    (era <C-i>; <C-i>=Tab: conflitto)
--   <C-t>      aggiunge " --type "
--   <M-s>      aggiunge " -s"         (case-Sensitive)
--   <M-i>      aggiunge " -i"         (case-Insensitive / ignore-case)
--   <M-w>      aggiunge " -w"         (Word-regexp, parola intera)
--   <M-f>      aggiunge " -F"         (Fixed-strings, no regex)
--   <M-p>      chiede il Path e riapre la ricerca limitata a quel path
--   <C-space>  passa a fuzzy-refine nella lista gia' filtrata
-- ============================================================

local km = require("keymaps") -- prefissi centralizzati
return {

  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nosduco/remote-sshfs.nvim",
      "nvim-lua/plenary.nvim",
      "BurntSushi/ripgrep",
      "sharkdp/fd",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
      "nvim-telescope/telescope-live-grep-args.nvim",
      -- Call hierarchy ad albero ricorsivo (sostituisce lsp_incoming/outgoing_calls)
      "jmacadie/telescope-hierarchy.nvim",
      "nvim-web-devicons",
      "nvim-treesitter/nvim-treesitter",
      "xiyaowong/telescope-emoji.nvim",
      "ghassan0/telescope-glyph.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      "lpoto/telescope-docker.nvim",
      "debugloop/telescope-undo.nvim",
    },

    config = function()
      local telescope = require("telescope")
      local actions   = require("telescope.actions")
      local lga       = require("telescope-live-grep-args.actions")

      -- ── Azione: limita la ricerca a un path specifico ──────
      -- Chiude telescope, chiede il path con vim.ui.input,
      -- poi riapre live_grep_args con "pattern path" gia' nella query.
      -- Il separatore di path in rg e' un argomento posizionale:
      --   rg pattern ./src/   oppure   rg pattern -- ./src/
      local function action_restrict_path(prompt_bufnr)
        local state   = require("telescope.actions.state")
        local current = state.get_current_line()
        actions.close(prompt_bufnr)
        vim.schedule(function()
          vim.ui.input(
            { prompt = "Cerca in path (es. ./src/  o  src/lib): ",
              default = "./" },
            function(path)
              if not path then return end
              path = vim.trim(path)
              if path == "" then
                telescope.extensions.live_grep_args.live_grep_args()
                return
              end
              -- Compone la query: "pattern path"
              -- rg interpreta il path come directory/file da cercare
              local sep   = (current ~= "" and not current:match("%s$")) and " " or ""
              local query = current .. sep .. path
              telescope.extensions.live_grep_args.live_grep_args({
                default_text = query,
              })
            end)
        end)
      end

      telescope.setup({
        defaults = {
          layout_strategy = "horizontal",
          layout_config   = { height = 0.999, width = 0.999 },
          mappings = {
            i = { ["<M-d>"] = actions.delete_buffer },
            n = { ["<M-d>"] = actions.delete_buffer },
          },
        },
        extensions = {

          live_grep_args = {
            auto_quoting = true,
            mappings = {
              i = {
                -- Virgolette attorno al pattern (utile per spazi)
                ["<C-o>"] = lga.quote_prompt(),

                -- Glob: era <C-i> che in terminale = <Tab> (conflitto)
                -- <M-g> → appende " --glob "
                -- es.: TODO <M-g> → "TODO" --glob  poi scrivi: *.py
                ["<M-g>"] = lga.quote_prompt({ postfix = " --glob " }),

                -- Tipo file rg (rg --type-list per la lista completa)
                -- es.: TODO <C-t> → "TODO" --type  poi scrivi: py
                ["<C-t>"] = lga.quote_prompt({ postfix = " --type " }),

                -- Case sensitivity
                -- -s = --case-sensitive  (forza maiuscole/minuscole)
                -- -i = --ignore-case     (ignora maiuscole/minuscole)
                -- Default di rg: --smart-case (sensibile se uppercase)
                ["<M-s>"] = lga.quote_prompt({ postfix = " -s" }),
                ["<M-i>"] = lga.quote_prompt({ postfix = " -i" }),

                -- Word regexp: matcha solo come parola intera
                -- es.: "log" -w NON matcha "logger" ne' "syslog"
                ["<M-w>"] = lga.quote_prompt({ postfix = " -w" }),

                -- Fixed strings: tratta il pattern come stringa letterale
                -- (nessun metacarattere regex: utile per cercare "a.b()")
                ["<M-f>"] = lga.quote_prompt({ postfix = " -F" }),

                -- Restrizione path: input interattivo + riapertura
                ["<M-p>"] = action_restrict_path,

                -- Fuzzy refine nella lista gia' filtrata
                ["<C-space>"] = lga.to_fuzzy_refine,
              },
            },
          },

          ["ui-select"] = { require("telescope.themes").get_dropdown({}) },

          -- ── telescope-hierarchy: call hierarchy ad albero ────
          -- Sostituisce il builtin lsp_incoming/outgoing_calls con
          -- una vista ricorsiva espandibile. Richiede un LSP con
          -- callHierarchyProvider (basedpyright, ts_ls, clangd …).
          --
          -- Tasti nella finestra hierarchy (normal mode):
          --   e / l / →   espandi nodo (un livello)
          --   c / h / ←   collassa nodo
          --   E           espandi multi-livello (multi_depth)
          --   t           toggle espandi/collassa
          --   s           inverti direzione (incoming ↔ outgoing)
          --   d           vai alla DEFINIZIONE del nodo
          --   CR          vai alla posizione della chiamata
          --   q / ESC     chiudi
          hierarchy = {
            initial_multi_expand = false,  -- espandi automaticamente all'apertura
            multi_depth          = 5,      -- livelli di espansione con 'E'
            layout_strategy      = "horizontal",
          },
        },
      })

      for _, ext in ipairs({
        "docker", "emoji", "fzf", "glyph",
        "hierarchy", "live_grep_args", "remote-sshfs", "ui-select", "undo",
      }) do
        telescope.load_extension(ext)
      end

      local builtin = require("telescope.builtin")
      local lga_sc  = require("telescope-live-grep-args.shortcuts")
      local sshfs_c = require("remote-sshfs.connections")
      local sshfs_a = require("remote-sshfs.api")

      -- ── Remote/sshfs ─────────────────────────────────────
      vim.keymap.set("n", km.remote .. "c", sshfs_a.connect,    { desc = "Remote: connect" })
      vim.keymap.set("n", km.remote .. "d", sshfs_a.disconnect, { desc = "Remote: disconnect" })
      vim.keymap.set("n", km.remote .. "e", sshfs_a.edit,       { desc = "Remote: edit" })

      -- ── File pickers ──────────────────────────────────────
      vim.keymap.set("n", km.find .. "f", function()
        if sshfs_c.is_connected() then sshfs_a.find_files()
        else builtin.find_files() end
      end, { desc = "Find: files" })

      vim.keymap.set("n", km.find .. "h", function()
        if sshfs_c.is_connected() then sshfs_a.find_files({ hidden = true })
        else builtin.find_files({ hidden = true }) end
      end, { desc = "Find: files (+ hidden)" })

      -- ── <leader>fg: live grep + argomenti rg ─────────────
      vim.keymap.set("n", km.find .. "g", function()
        if sshfs_c.is_connected() then sshfs_a.live_grep()
        else telescope.extensions.live_grep_args.live_grep_args() end
      end, { desc = "Find: grep (rg args: -s -i -w -F path)" })

      vim.keymap.set("n", km.find .. "v", lga_sc.grep_visual_selection, { desc = "Find: grep visual" })
      vim.keymap.set("n", km.find .. "c", lga_sc.grep_word_under_cursor, { desc = "Find: grep word" })
      vim.keymap.set("n", km.find .. "s", builtin.grep_string,           { desc = "Find: string under cursor" })

      -- ── Vim pickers ───────────────────────────────────────
      vim.keymap.set("n", km.view .. "a", builtin.autocommands,             { desc = "View: autocommands" })
      vim.keymap.set("n", km.view .. "b", builtin.buffers,                  { desc = "View: buffers" })
      vim.keymap.set("n", km.view .. "B", builtin.builtin,                  { desc = "View: builtins" })
      vim.keymap.set("n", km.view .. "c", builtin.commands,                 { desc = "View: commands" })
      vim.keymap.set("n", km.view .. "e", telescope.extensions.emoji.emoji, { desc = "View: emoji" })
      vim.keymap.set("n", km.view .. "f", builtin.filetypes,                { desc = "View: filetypes" })
      vim.keymap.set("n", km.view .. "g", telescope.extensions.glyph.glyph, { desc = "View: glyph" })
      vim.keymap.set("n", km.view .. "h", builtin.highlights,               { desc = "View: highlights" })
      vim.keymap.set("n", km.view .. "i", function() vim.cmd("Telescope hierarchy incoming_calls") end, { desc = "View: incoming calls (tree)" })
      vim.keymap.set("n", km.view .. "j", builtin.jumplist,                 { desc = "View: jumps" })
      vim.keymap.set("n", km.view .. "k", builtin.keymaps,                  { desc = "View: keymaps" })
      vim.keymap.set("n", km.view .. "l", builtin.loclist,                  { desc = "View: loclist" })
      vim.keymap.set("n", km.view .. "m", builtin.marks,                    { desc = "View: marks" })
      vim.keymap.set("n", km.view .. "o", function() vim.cmd("Telescope hierarchy outgoing_calls") end,  { desc = "View: outgoing calls (tree)" })
      vim.keymap.set("n", km.view .. "O", builtin.vim_options,              { desc = "View: vim options" })
      vim.keymap.set("n", km.view .. "p", builtin.man_pages,                { desc = "View: man pages" })
      vim.keymap.set("n", km.view .. "q", builtin.quickfix,                 { desc = "View: quickfix" })
      vim.keymap.set("n", '<leader>v"', builtin.registers,                { desc = "View: registers" })
      vim.keymap.set("n", km.view .. "r", builtin.reloader,                 { desc = "View: lua modules" })
      vim.keymap.set("n", km.view .. "s", builtin.symbols,                  { desc = "View: symbols" })
      vim.keymap.set("n", km.view .. "t", builtin.tags,                     { desc = "View: tags" })
      vim.keymap.set("n", km.view .. "u", telescope.extensions.undo.undo,   { desc = "View: undo tree" })
      vim.keymap.set("n", km.view .. "T", builtin.current_buffer_tags,      { desc = "View: buffer tags" })
      vim.keymap.set("n", km.view .. "z", builtin.spell_suggest,            { desc = "View: spell suggest" })
      vim.keymap.set("n", km.view .. "!", builtin.treesitter,               { desc = "View: treesitter symbols" })
      vim.keymap.set("n", km.view .. "/", builtin.search_history,           { desc = "View: search history" })
      vim.keymap.set("n", km.view .. "&", builtin.command_history,          { desc = "View: command history" })
      vim.keymap.set("n", km.view .. "?", builtin.help_tags,                { desc = "View: help tags" })
      vim.keymap.set("n", km.view .. "~", builtin.colorscheme,              { desc = "View: colorschemes" })
      vim.keymap.set("n", km.view .. "d", builtin.diagnostics,              { desc = "View: diagnostics" })
      vim.keymap.set("n", km.view .. "n", "<CMD>TodoTelescope<CR>",         { desc = "View: notes/TODO" })

      -- ── Git pickers ───────────────────────────────────────
      vim.keymap.set("n", km.git .. "b", builtin.git_branches, { desc = "Git: branches" })
      vim.keymap.set("n", km.git .. "B", builtin.git_bcommits, { desc = "Git: blame" })
      vim.keymap.set("n", km.git .. "c", builtin.git_commits,  { desc = "Git: commits" })
      vim.keymap.set("n", km.git .. "s", builtin.git_status,   { desc = "Git: status" })
      vim.keymap.set("n", km.git .. "S", builtin.git_stash,    { desc = "Git: stash" })

      -- ── Docker ────────────────────────────────────────────
      for key, cmd in pairs({
        c = "containers", d = "docker",   f = "files",
        i = "images",     m = "machines", n = "networks",
        o = "contexts",   s = "swarm",    v = "volumes",
      }) do
        vim.keymap.set("n", km.docker .. key,
          telescope.extensions.docker[cmd],
          { desc = "Docker: " .. cmd })
      end
    end,
  },

}
