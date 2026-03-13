local theme_browser = {
  dev = {
    enabled = vim.env.THEME_BROWSER_DEV == "1",
    dir = "~/projects/theme-browser-monorepo/packages/plugin",
  },
  opts = {
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
      mode = "manual",
      provider = "auto",
    },
  },
}

if theme_browser.dev.enabled then
  theme_browser.opts.development = {
    enabled = true,
    registry_path = "~/projects/theme-browser-monorepo/packages/registry/artifacts/themes.json",
    local_repo_sources = {
      "~/projects",
    },
  }
end

return theme_browser
