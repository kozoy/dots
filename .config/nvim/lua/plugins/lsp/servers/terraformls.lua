-- lua/plugins/lsp/servers/terraformls.lua
return {
  filetypes = { "terraform", "tf" },
  init_options = { experimentalFeatures = { validateOnSave = true } },
}
