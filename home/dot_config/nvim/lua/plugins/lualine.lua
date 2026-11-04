return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options.section_separators = ""
      opts.options.component_separators = ""

      opts.sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = {
          { "diagnostics", sections = { "error", "warn" } },
        },
        lualine_y = { "location" },
        lualine_z = {},
      }
    end,
  },
}
