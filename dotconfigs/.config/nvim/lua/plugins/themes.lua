-- Extra colorschemes; all lazy, listed by <leader>uC without startup cost.

return {
  { "rebelot/kanagawa.nvim", lazy = true },
  { "EdenEast/nightfox.nvim", lazy = true },
  { "kepano/flexoki-neovim", lazy = true },
  { "rose-pine/neovim", name = "rose-pine", lazy = true },
  { "ellisonleao/gruvbox.nvim", lazy = true },
  { "projekt0n/github-nvim-theme", lazy = true },
  { "nyoom-engineering/oxocarbon.nvim", lazy = true, build = false },
  { "scottmckendry/cyberdream.nvim", lazy = true },
  { "bluz71/vim-moonfly-colors", name = "moonfly", lazy = true },
  { "zenbones-theme/zenbones.nvim", lazy = true, dependencies = { "rktjmp/lush.nvim" } },
}
