-- lsp/ts_ls.lua
local inlay_hints = {
  includeInlayParameterNameHints                          = "all",
  includeInlayParameterNameHintsWhenArgumentMatchesName   = false,
  includeInlayFunctionParameterTypeHints                  = true,
  includeInlayVariableTypeHints                           = true,
  includeInlayVariableTypeHintsWhenTypeMatchesName        = false,
  includeInlayPropertyDeclarationTypeHints                = true,
  includeInlayFunctionLikeReturnTypeHints                 = true,
  includeInlayEnumMemberValueHints                        = true,
  -- "↑ BaseClass.method" inline quando il metodo ridefinisce la superclasse
  includeInlayMethodOverrideHints                         = true,
}

return {
  filetypes    = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
  settings = {
    typescript  = { inlayHints = inlay_hints },
    javascript  = { inlayHints = inlay_hints },
  },
}
