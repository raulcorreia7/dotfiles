-- Extra colorschemes; all lazy, listed by <leader>uC without startup cost.
return {
  { "rebelot/kanagawa.nvim", lazy = true },
  { "EdenEast/nightfox.nvim", lazy = true },
  { "kepano/flexoki-neovim", lazy = true },
  {
    "baliestri/aura-theme",
    lazy = true,
    config = function(plugin)
      vim.opt.rtp:append(plugin.dir .. "/packages/neovim")
    end,
  },
  { "rose-pine/neovim", name = "rose-pine", lazy = true },
  { "ellisonleao/gruvbox.nvim", lazy = true },
  { "projekt0n/github-nvim-theme", name = "github-theme", lazy = true },
  { "cocopon/iceberg.vim", name = "iceberg", lazy = true },
  { "navarasu/onedark.nvim", lazy = true },
  { "1amSimp1e/dots", lazy = true },
  { "nyoom-engineering/oxocarbon.nvim", lazy = true, build = false }, -- avoid luarocks build
  { "nyoom-engineering/nyoom.nvim", lazy = true },
  { "scottmckendry/cyberdream.nvim", lazy = true },
  { "bluz71/vim-moonfly-colors", name = "moonfly", lazy = true },
  { "jacoborus/tender.vim", name = "tender", lazy = true },
  { "vague-theme/vague.nvim", lazy = true },
  { "mhartington/oceanic-next", name = "OceanicNext", lazy = true },
  { "zenbones-theme/zenbones.nvim", lazy = true, dependencies = { "rktjmp/lush.nvim" } },
  { "olimorris/onedarkpro.nvim", lazy = true },
  { "marko-cerovac/material.nvim", lazy = true },
  { "thesimonho/kanagawa-paper", branch = "neovim", lazy = true, opts = {} }, -- runtime lives on the neovim branch
  { "sainnhe/sonokai", lazy = true },
  { "sainnhe/edge", lazy = true },
  { "savq/melange-nvim", lazy = true },
}
