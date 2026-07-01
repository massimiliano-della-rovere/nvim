-- ============================================================
-- plugins/treesitter.lua  --  Neovim 0.12 / 0.13-compatible
-- ============================================================
-- nvim-treesitter/nvim-treesitter e' stato archiviato il 3 aprile
-- 2026 (congelato, non si rompe ma non ricevera' piu' aggiornamenti
-- di parser/fix). Questo file lo sostituisce con un'architettura
-- 100% nativa + un installer di parser leggero e indipendente:
--
--   romus204/tree-sitter-manager.nvim
--     Installa/aggiorna i parser (.so) e copia le query di
--     evidenziazione. NON dipende dal codice di nvim-treesitter.
--     Requisiti di sistema: tree-sitter CLI, git, compilatore C.
--
--   highlighting / indent / folding
--     Forniti nativamente da vim.treesitter (nessun plugin):
--       vim.treesitter.start()              -- evidenziazione
--       vim.treesitter.indentexpr()          -- indentazione
--       vim.treesitter.foldexpr()            -- folding (gia' in
--                                                set_options.lua)
--
--   maxischmaxi/inc-select.nvim
--     Sostituisce il modulo incremental_selection rimosso dal
--     branch main di nvim-treesitter (stesso schema di keymap).
--
--   nvim-treesitter/nvim-treesitter-textobjects (branch "main")
--     Ora e' uno plugin standalone: non chiama piu' l'API interna
--     di nvim-treesitter, usa solo vim.treesitter. Serve solo che
--     i parser siano installati da qualcosa (tree-sitter-manager).
-- ============================================================

local km = require("keymaps") -- prefissi centralizzati

-- Linguaggi gia' compilati nel binario di Neovim: non richiedono
-- installazione, e tree-sitter-manager.nvim li esclude di default
-- da auto_install tramite noauto_install.
local bundled_languages = {
  "c", "lua", "markdown", "markdown_inline", "query", "vim", "vimdoc", "regex",
}

-- Linguaggi da installare in anticipo all'avvio, equivalente del
-- vecchio ensure_installed (i bundled qui sopra sono esclusi: non
-- serve installarli).
--
-- NOTA "unison" rimosso: non esiste nel registry repos.lua di
-- tree-sitter-manager.nvim (mirror del vecchio registry di
-- nvim-treesitter, che non includeva mai Unison ufficialmente).
-- Il filetype unison resta coperto dalla syntax legacy fornita da
-- unisonweb/unison in programming.lua (vim regex, non treesitter).
local ensure_installed = {
  "bash", "css", "javascript", "python", "sql", "typescript",
}

-- Installa (in background, una sola volta) i parser di
-- ensure_installed non ancora presenti su disco. Controllo difensivo
-- via filesystem invece che via API interna del plugin (di cui non
-- e' documentata pubblicamente una funzione "is_installed"),
-- cosi' resta valido anche se l'API interna cambia.
local function install_missing_parsers()
  local parser_dir = vim.fn.stdpath("data") .. "/site/parser"
  local missing = {}
  for _, lang in ipairs(ensure_installed) do
    local so_unix = parser_dir .. "/" .. lang .. ".so"
    local so_win = parser_dir .. "/" .. lang .. ".dll"
    if vim.fn.filereadable(so_unix) == 0 and vim.fn.filereadable(so_win) == 0 then
      table.insert(missing, lang)
    end
  end
  if #missing > 0 then
    vim.schedule(function()
      local ok = pcall(vim.cmd, "TSInstall " .. table.concat(missing, " "))
      if not ok then
        vim.notify(
          "tree-sitter-manager: installazione automatica fallita per: "
            .. table.concat(missing, ", ")
            .. ". Esegui manualmente :TSInstall <lang> o :TSManager.",
          vim.log.levels.WARN
        )
      end
    end)
  end
end

-- Evidenziazione + indentazione native, equivalenti a
-- highlight.enable/indent.enable del vecchio modulo. La soglia sui
-- file grandi replica il vecchio highlight.disable (>100KB).
local function setup_native_highlight_and_indent()
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("NativeTreesitter", { clear = true }),
    callback = function(args)
      local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
      local too_big = ok and stats and stats.size > 100 * 1024
      if too_big then return end

      -- Solo highlighting treesitter nativo.
      -- NON impostiamo indentexpr: vim.treesitter.indentexpr()
      -- richiede indent queries (indent.scm) che erano fornite dalla
      -- cartella queries/ di nvim-treesitter. Senza di esse restituisce
      -- -1 per ogni <CR>, portando il cursore a colonna 1 anche quando
      -- il parser e' installato (es. Python). L'indentazione viene
      -- gestita dai ftplugin nativi di Neovim (python3indent, cindent,
      -- ecc.) che sono gia' corretti e non richiedono treesitter.
      pcall(vim.treesitter.start, args.buf)
    end,
  })
end

-- Sostituto nativo di textobjects.lsp_interop.peek_definition_code:
-- mostra la definizione del simbolo sotto cursore in una finestra
-- flottante, senza lasciare il buffer corrente. Differenza
-- semantica dall'originale: l'originale faceva peek della funzione/
-- classe "enclosing" individuata da treesitter; questa versione fa
-- peek della definizione LSP del simbolo sotto cursore (comportamento
-- standard "go to definition" ma senza saltare via). Usa solo API
-- pubbliche e documentate di vim.lsp (stabili su 0.12 e 0.13).
local function lsp_peek_definition()
  local clients = vim.lsp.get_clients({ bufnr = 0, method = "textDocument/definition" })
  if #clients == 0 then
    vim.notify("Nessun LSP client con supporto a 'definition' su questo buffer", vim.log.levels.WARN)
    return
  end
  local params = vim.lsp.util.make_position_params(0, clients[1].offset_encoding)
  vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result)
    if err or not result or vim.tbl_isempty(result) then
      vim.notify("Nessuna definizione trovata", vim.log.levels.INFO)
      return
    end
    local location = result[1] or result
    pcall(vim.lsp.util.preview_location, location, { border = "single" })
  end)
end

return {

  -- ── tree-sitter-manager.nvim: installer dei parser ───────
  {
    "romus204/tree-sitter-manager.nvim",
    lazy = false,
    -- Requisiti di sistema (non installabili da qui):
    --   tree-sitter CLI, git, compilatore C (gcc/clang)
    config = function()
      require("tree-sitter-manager").setup({
        -- Path di default: dentro stdpath("data")/site, che e'
        -- automaticamente su 'runtimepath' (vedi :h packages).
        -- nvim-treesitter-context e nvim-treesitter-textobjects
        -- (sotto) cercano i parser solo via vim.treesitter, che
        -- scansiona runtimepath: percorso compatibile, nessuna
        -- modifica a rtp necessaria.
        parser_dir = vim.fn.stdpath("data") .. "/site/parser",
        query_dir = vim.fn.stdpath("data") .. "/site/queries",

        -- Installa automaticamente il parser mancante quando apri
        -- un file di un tipo non ancora installato (equivalente al
        -- vecchio auto_install = true).
        auto_install = true,
        noauto_install = bundled_languages,
      })

      install_missing_parsers()
    end,
  },

  -- ── nvim-treesitter-textobjects (standalone, branch main) ─
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    lazy = false,
    config = function()
      setup_native_highlight_and_indent()

      require("nvim-treesitter-textobjects").setup({
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            -- Funzioni e metodi
            ["af"] = { query = "@function.outer", desc = "outer function" },
            ["if"] = { query = "@function.inner", desc = "inner function" },
            -- Classi
            ["ac"] = { query = "@class.outer", desc = "outer class" },
            ["ic"] = { query = "@class.inner", desc = "inner class" },
            -- Parametri
            ["aa"] = { query = "@parameter.outer", desc = "outer parameter" },
            ["ia"] = { query = "@parameter.inner", desc = "inner parameter" },
            -- Loop
            ["al"] = { query = "@loop.outer", desc = "outer loop" },
            ["il"] = { query = "@loop.inner", desc = "inner loop" },
            -- Condizionali
            ["ai"] = { query = "@conditional.outer", desc = "outer if" },
            ["ii"] = { query = "@conditional.inner", desc = "inner if" },
            -- Blocchi
            ["ab"] = { query = "@block.outer", desc = "outer block" },
            ["ib"] = { query = "@block.inner", desc = "inner block" },
            -- Call
            ["aF"] = { query = "@call.outer", desc = "outer call" },
            ["iF"] = { query = "@call.inner", desc = "inner call" },
          },
          selection_modes = {
            ["@parameter.outer"] = "v",
            ["@function.outer"] = "V",
            ["@class.outer"] = "V",
          },
          include_surrounding_whitespace = false,
        },

        -- Swap argomenti con <M-,> e <M-.>
        swap = {
          enable = true,
          swap_next = { ["<M-.>"] = "@parameter.inner" },
          swap_previous = { ["<M-,>"] = "@parameter.inner" },
        },

        -- Move: salta al prossimo/precedente nodo sintattico.
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]f"] = { query = "@function.outer", desc = "Next function" },
            ["]k"] = { query = "@class.outer", desc = "Next class" },
          },
          goto_next_end = {
            ["]F"] = { query = "@function.outer", desc = "Next function end" },
            ["]K"] = { query = "@class.outer", desc = "Next class end" },
          },
          goto_previous_start = {
            ["[f"] = { query = "@function.outer", desc = "Prev function" },
            ["[k"] = { query = "@class.outer", desc = "Prev class" },
          },
          goto_previous_end = {
            ["[F"] = { query = "@function.outer", desc = "Prev function end" },
            ["[K"] = { query = "@class.outer", desc = "Prev class end" },
          },
        },
      })

      -- Sostituto nativo di lsp_interop.peek_definition_code
      -- (vedi commento sulla funzione lsp_peek_definition sopra).
      vim.keymap.set("n", km.lsp .. "p", lsp_peek_definition, { desc = "LSP: peek definition" })
      vim.keymap.set("n", km.lsp .. "P", lsp_peek_definition, { desc = "LSP: peek definition" })
    end,
  },

  -- ── inc-select.nvim: incremental selection nativa ─────────
  -- Sostituisce il modulo incremental_selection rimosso dal branch
  -- main di nvim-treesitter, stessi 4 keymap di prima.
  {
    "maxischmaxi/inc-select.nvim",
    lazy = false,
    config = function()
      require("inc-select").setup({
        keymaps = {
          init_selection = "<CR>",
          node_incremental = "<CR>",
          scope_incremental = "<TAB>",
          node_decremental = "<BS>",
        },
      })
    end,
  },

  -- ── nvim-treesitter-context ───────────────────────────────
  -- ============================================================
  -- Mostra in cima alla finestra il contesto corrente
  -- (nome della funzione, classe, loop) quando scorri lontano
  -- dalla definizione. Identico al comportamento di IntelliJ.
  --
  -- [C  →  salta al contesto corrente (utile per vedere la firma
  --         della funzione in cui sei, poi torna con <C-o>)
  --
  -- Compatibilita' parser: usa solo vim.treesitter (nessuna
  -- dipendenza su nvim-treesitter), quindi legge i parser dalla
  -- stessa posizione standard su runtimepath in cui li installa
  -- tree-sitter-manager.nvim (stdpath("data")/site/parser).
  -- ============================================================
  {
    "nvim-treesitter/nvim-treesitter-context",
    config = function()
      require("treesitter-context").setup({
        enable = true,
        max_lines = 4, -- max righe di contesto mostrate
        min_window_height = 20, -- non mostra su finestre piccole
        line_numbers = true,
        multiline_threshold = 3, -- tronca contesti multi-riga lunghi
        trim_scope = "outer", -- se troppo lungo, tronca dall'esterno
        mode = "cursor",
        separator = "\xe2\x94\x80", -- ─ separatore visivo
        zindex = 20,
        on_attach = nil, -- callback opzionale
      })

      -- Highlight: rende il contesto leggermente distinto
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("TSContextHL", { clear = true }),
        callback = function()
          -- Copia il colore di CursorLine con fg più chiaro
          vim.api.nvim_set_hl(0, "TreesitterContext", { link = "CursorLine", default = false })
          vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", { link = "CursorLineNr", default = false })
          vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { link = "Comment", default = false })
        end,
      })

      -- [C: salta al contesto (uppercase per non confondere con ]c di gitsigns)
      vim.keymap.set("n", "[C", function()
        require("treesitter-context").go_to_context(vim.v.count1)
      end, { desc = "TSContext: jump to context" })
    end,
  },
}
