return {
  {
    dir = "/home/rcorreia/projects/theme-browser-monorepo/theme-browser.nvim",
    name = "theme-browser.nvim",
    cmd = {
      "ThemeBrowser",
      "ThemeBrowserUse",
      "ThemeBrowserStatus",
      "ThemeBrowserRegistrySync",
      "ThemeBrowserRegistryClear",
      "ThemeBrowserReset",
      "ThemeBrowserHelp",
      "ThemeBrowserValidate",
    },
    event = "VeryLazy",
    dependencies = {
      "rktjmp/lush.nvim",
    },
    opts = {
      registry_path = "/home/rcorreia/projects/theme-browser-monorepo/theme-browser-registry/themes.json",
      auto_load = false,
      startup = {
        enabled = true,
        write_spec = true,
        skip_if_already_active = true,
      },
      ui = {
        preview_on_move = true,
      },
      package_manager = {
        enabled = true,
      },
    },
    config = function(_, opts)
      require("theme-browser").setup(opts)
    end,
  },
}
