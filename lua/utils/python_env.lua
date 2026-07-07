-- lua/utils/python_env.lua
-- ============================================================
-- Rilevamento dell'ambiente Python attivo a runtime.
-- Usato da mason_lsp.lua e formatting.lua per selezionare
-- tool compatibili con la versione Python del sistema/venv.
-- ============================================================

local M = {}

-- Restituisce true se l'ambiente corrente è Python 2.x.
-- Controlli in cascata (dal più specifico al più generale):
--
--   1. $VIRTUAL_ENV contiene "py2" o "python2"
--      (es. /tcwa/venv/py2.7.16 → true)
--
--   2. `python --version` restituisce "Python 2.x"
--      (cattura il caso in cui python2 è il default di sistema
--       ma non c'è un venv attivo)
--
-- Più robusto dell'hostname: funziona anche se il container
-- viene rinominato o replicato, e gestisce venv Python 2
-- su sistemi altrimenti Python 3.
--
-- Il risultato è memoizzato: la funzione esegue io.popen
-- al massimo una volta per sessione Neovim.
local _cache = nil
function M.is_python2()
  if _cache ~= nil then return _cache end

  -- Controllo 1: VIRTUAL_ENV
  local venv = os.getenv("VIRTUAL_ENV") or ""
  if venv:match("py2") or venv:match("python2") then
    _cache = true
    return _cache
  end

  -- Controllo 2: versione dell'interprete python nel PATH
  local handle = io.popen("python --version 2>&1")
  if handle then
    local ver = handle:read("*l") or ""
    handle:close()
    if ver:match("^Python 2%.") then
      _cache = true
      return _cache
    end
  end

  _cache = false
  return _cache
end

return M
