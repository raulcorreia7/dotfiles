-- Not documented by LazyVim (see LazyVim/LazyVim#4884, closed): picks made
-- with <leader>uC are persisted here to stdpath("data")/theme and re-applied
-- on startup. No hardcoded colorscheme; none picked yet = LazyVim default.
local pinfile = vim.fn.stdpath("data") .. "/theme"

local function apply(name)
  -- lazy.nvim auto-loads plugin-owned colorschemes; aura-theme is the one
  -- exception (colors live under packages/neovim, added by its config).
  if name:find("^aura") then
    pcall(require("lazy").load, { plugins = { "aura-theme" } })
  end
  vim.cmd.colorscheme(name)
end

return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        local f = io.open(pinfile, "r")
        local name = f and f:read("*l")
        if f then
          f:close()
        end
        if name then
          apply(name)
        else
          require("tokyonight").load()
        end
      end,
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          colorschemes = {
            confirm = function(picker, item)
              picker:close()
              if item then
                -- keep the previewer from restoring the old colorscheme
                -- (same as the default confirm in snacks config/sources.lua)
                picker.preview.state.colorscheme = nil
                vim.schedule(function()
                  local w = assert(io.open(pinfile, "w"))
                  w:write(item.text)
                  w:close()
                  apply(item.text)
                end)
              end
            end,
          },
        },
      },
    },
  },
}
