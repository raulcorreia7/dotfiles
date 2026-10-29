-- https://www.lazyvim.org/plugins/lsp#-customizing-lsp-server-settings
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      -- rebof3: .clangd + build/compile_commands.json drive clangd;
      -- regenerate the db after build-system changes with `make split`
      clangd = {},
    },
  },
}
