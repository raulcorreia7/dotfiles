return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
          },
          files = {
            -- hidden = true, -- show dotfiles in fuzzy finder
            -- ignored = true, -- optional: show gitignored files
          },
        },
      },
    },
  },
}
