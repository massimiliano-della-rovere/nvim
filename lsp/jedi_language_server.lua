-- lsp/jedi_language_server.lua
-- ============================================================
-- Usato al posto di basedpyright sul container Bookworm/Python 2.7.
-- Jedi ha supporto eccellente per Python 2.7: analisi del codice,
-- completamenti, goto definition, hover, riferimenti.
-- Il server gira su Python 3.11 (disponibile su Bookworm), ma
-- punta all'interprete Python 2.7 per l'analisi dell'ambiente.
-- ============================================================

-- Usa il virtualenv attivo se presente, altrimenti cerca python2.7
-- di sistema. La priorita' e':
--   1. $VIRTUAL_ENV/bin/python  (venv esplicitamente attivato)
--   2. python2.7 di sistema     (es. /tcwa/venv/py2.7.16/bin/python)
--   3. nil                      (jedi usa il python che trova nel PATH)
local python_path
local venv = os.getenv("VIRTUAL_ENV")
if venv then
  python_path = venv .. "/bin/python"
else
  -- Cerca python2.7 nel PATH; se non trovato, lascia decidere a jedi.
  local handle = io.popen("command -v python2.7 2>/dev/null")
  if handle then
    local result = handle:read("*l")
    handle:close()
    if result and result ~= "" then
      python_path = result
    end
  end
end

return {
  cmd          = { "jedi-language-server" },
  filetypes    = { "python" },
  root_markers = {
    "pyproject.toml", "setup.py", "setup.cfg",
    "requirements.txt", ".git",
  },
  settings = {
    jedi = {
      interpreter = {
        -- Punta all'interprete Python 2.7 per completamenti e analisi
        -- corretti dell'ambiente (stdlib 2.7, moduli installati nel venv).
        projectedEnvironments = python_path and { { pythonPath = python_path } } or nil,
      },
      completion = {
        disableSnippets  = false,
        resolveEagerly   = false,
        ignorePatterns   = {},
      },
      diagnostics = {
        enable           = true,
        didOpen          = true,
        didChange        = true,
        didSave          = true,
      },
      hover = {
        enable           = true,
        disable          = { class = {}, function_ = {}, instance = {}, keyword = {}, module = {}, param = {}, path = {}, property = {}, statement = {} },
      },
      jediSettings = {
        autoImportModules = {},
        caseInsensitiveCompletion = true,
      },
    },
  },
  -- jedi-language-server non supporta ancora tutti i workspace/did_change_watched_files
  -- capabilities: limitiamo per evitare warning inutili.
  capabilities = {
    workspace = {
      didChangeWatchedFiles = { dynamicRegistration = false },
    },
  },
}
