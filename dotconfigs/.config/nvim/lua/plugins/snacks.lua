return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    picker = {
      -- show dotfiles by default in the explorer and all pickers
      hidden = true,
      -- but keep git internals out of every picker and the tree
      exclude = { ".git" },
      -- keep .gitignore respected (toggled with <a-i> / explorer "I")
      ignored = false,
    },
    -- replace LazyVim's banner with snacks' current upstream default header
    -- (lua/snacks/dashboard.lua @ main, verified 2026-10-30)
    dashboard = {
      preset = {
        header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
      },
    },
  },
}
