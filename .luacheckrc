-- Luacheck configuration for Neovim config files
std = "luajit"

globals = {
  "vim",
}

-- Ignora warning su variabili non usate che iniziano con _
unused_args = false
redefined = false

-- Ignora campi sconosciuti degli oggetti (come vim.api.*)
max_line_length = false
