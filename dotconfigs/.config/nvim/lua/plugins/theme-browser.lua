local theme_browser = require("config.theme-browser")
local plugin_dir = nil

if theme_browser.dev.enabled then
  local expanded = vim.fn.expand(theme_browser.dev.dir)
  if expanded ~= "" and vim.fn.isdirectory(expanded) == 1 then
    plugin_dir = expanded
  end
end

return {
  {
    "raulcorreia7/theme-browser.nvim",
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
    dir = plugin_dir,
    opts = theme_browser.opts,
  },
}
