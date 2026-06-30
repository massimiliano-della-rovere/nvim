-- ============================================================
-- plugins/testing.lua  --  Neovim 0.12 / 0.13-compatible
-- ============================================================
-- neotest: framework per eseguire test direttamente in Neovim.
--
-- Adapter inclusi:
--   neotest-python   pytest / unittest
--   neotest-vitest   Vitest (JS/TS)
--   neotest-plenary  busted (Lua)
--
-- KEYMAPS  (<leader>T):
--   <leader>Tt   esegui il test più vicino al cursore
--   <leader>TT   esegui tutti i test del file corrente
--   <leader>Ta   esegui tutti i test del progetto
--   <leader>Tl   ri-esegui l'ultimo test
--   <leader>Ts   apri/chiudi pannello summary
--   <leader>To   apri/chiudi output del test corrente
--   <leader>TO   apri output in finestra floating
--   <leader>Td   debug del test più vicino (richiede nvim-dap)
--   <leader>Tw   watch: ri-esegui al salvataggio
-- ============================================================

local km = require("keymaps") -- prefissi centralizzati
return {

  {
    "nvim-neotest/neotest",
    dependencies = {
      -- antoinemadec/FixCursorHold.nvim rimosso (2026): il bug di
      -- performance su CursorHold che risolveva è stato corretto nel
      -- core di Neovim dalla 0.8 in poi; lo stesso autore del plugin
      -- lo conferma nel README. Su 0.12/0.13 è inutile.
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- ── Adapter ────────────────────────────────────────
      "nvim-neotest/neotest-python",   -- pytest / unittest
      "marilari88/neotest-vitest",     -- Vitest
      "nvim-neotest/neotest-plenary",  -- busted (Lua)
    },
    config = function()
      local neotest = require("neotest")

      neotest.setup({
        -- ── Adapter ────────────────────────────────────────
        adapters = {
          require("neotest-python")({
            -- Usa il Python del virtualenv se disponibile
            python = function()
              local cwd = vim.fn.getcwd()
              for _, venv in ipairs({ "venv", ".venv", "env" }) do
                local py = cwd .. "/" .. venv .. "/bin/python"
                if vim.fn.executable(py) == 1 then return py end
              end
              local venv_env = os.getenv("VIRTUAL_ENV")
              if venv_env then return venv_env .. "/bin/python" end
              return "python3"
            end,
            runner       = "pytest",
            pytest_extra = { "--tb=short" },
          }),

          require("neotest-vitest")({
            -- Cerca il config di vitest nella root del progetto
            filter_dir = function(name)
              return name ~= "node_modules"
            end,
          }),

          require("neotest-plenary").setup({
            min_init = "./tests/minimal_init.lua",
          }),
        },

        -- ── Output ─────────────────────────────────────────
        output = {
          enabled      = true,
          open_on_run  = "short",  -- apre auto se test fallisce
        },

        output_panel = {
          enabled = true,
          open    = "botright split | resize 15",
        },

        -- ── Summary ────────────────────────────────────────
        summary = {
          enabled      = true,
          animated     = true,
          follow       = true,
          open         = "botright vsplit | vertical resize 50",
          mappings = {
            expand       = { "<CR>", "<2-LeftMouse>" },
            expand_all   = "e",
            output       = "o",
            short        = "O",
            run          = "r",
            run_marked   = "R",
            mark         = "m",
            debug        = "d",
            debug_marked = "D",
            stop         = "u",
            attach       = "a",
            jumpto       = "i",
            next_failed  = "]f",
            prev_failed  = "[f",
          },
        },

        -- ── Integrazione con nvim-dap ───────────────────────
        -- Attiva automaticamente se nvim-dap è caricato
        default_strategy = "integrated",

        -- ── Segni nella sign column ─────────────────────────
        -- Usa extmarks (non sign_define) per compatibilità 0.12+
        icons = {
          child_indent = "\xe2\x94\x82",   -- │
          child_prefix = "\xe2\x94\x9c",   -- ├
          collapsed    = "\xe2\x96\xb8",   -- ▸
          expanded     = "\xe2\x96\xbe",   -- ▾
          failed       = "\xe2\x9c\x97",   -- ✗
          final_child_indent = " ",
          final_child_prefix = "\xe2\x94\x94",  -- └
          non_collapsible = "\xe2\x94\x80",     -- ─
          passed       = "\xe2\x9c\x93",   -- ✓
          running      = "\xe2\x9f\xb3",   -- ⟳
          running_animated = { "|", "/", "-", "\\" },
          skipped      = "\xe2\x9e\x9c",   -- ➜
          unknown      = "?",
          watching     = "\xe2\x9f\xb3",
        },

        -- ── Diagnostics ─────────────────────────────────────
        diagnostic = {
          enabled  = true,
          severity = vim.diagnostic.severity.ERROR,
        },

        -- ── Log ─────────────────────────────────────────────
        log_level = vim.log.levels.WARN,
      })

      -- ── Keymaps ──────────────────────────────────────────
      local function nt(fn, desc)
        return function() neotest[fn]() end, { desc = "Test: " .. desc }
      end

      vim.keymap.set("n", km.test .. "t",
        function() neotest.run.run() end,
        { desc = "Test: run nearest" })
      vim.keymap.set("n", km.test .. "T",
        function() neotest.run.run(vim.fn.expand("%")) end,
        { desc = "Test: run file" })
      vim.keymap.set("n", km.test .. "a",
        function() neotest.run.run(vim.fn.getcwd()) end,
        { desc = "Test: run all" })
      vim.keymap.set("n", km.test .. "l",
        function() neotest.run.run_last() end,
        { desc = "Test: run last" })
      vim.keymap.set("n", km.test .. "s",
        function() neotest.summary.toggle() end,
        { desc = "Test: summary panel" })
      vim.keymap.set("n", km.test .. "o",
        function() neotest.output.open({ enter = true }) end,
        { desc = "Test: output" })
      vim.keymap.set("n", km.test .. "O",
        function() neotest.output_panel.toggle() end,
        { desc = "Test: output panel" })
      vim.keymap.set("n", km.test .. "d",
        function()
          neotest.run.run({ strategy = "dap" })
        end,
        { desc = "Test: debug nearest" })
      vim.keymap.set("n", km.test .. "w",
        function() neotest.watch.toggle(vim.fn.expand("%")) end,
        { desc = "Test: watch file" })
      vim.keymap.set("n", km.test .. "x",
        function() neotest.run.stop() end,
        { desc = "Test: stop" })
    end,
  },

}
