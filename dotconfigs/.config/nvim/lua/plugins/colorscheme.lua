-- Picked colorscheme is persisted to stdpath("data")/theme and re-applied at
-- startup. Snacks owns <leader>uC when the snacks picker is active; fzf-lua is
-- kept working because this config also enables the fzf extra.
local file = vim.fn.stdpath("data") .. "/theme"

return {
  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      if vim.fn.filereadable(file) == 1 then
        local name = vim.fn.readfile(file)[1]
        if name and name ~= "" then
          opts.colorscheme = name
        end
      end
    end,
  },
  {
    "ibhagwan/fzf-lua",
    optional = true,
    opts = function(_, opts)
      opts.colorschemes = vim.tbl_deep_extend("force", opts.colorschemes or {}, {
        actions = {
          ["enter"] = function(selected)
            local name = selected and selected[1] and selected[1]:match("^[^:]+")
            if name and name ~= "" and pcall(vim.cmd.colorscheme, name) then
              vim.fn.writefile({ name }, file)
            end
          end,
        },
      })
    end,
  },
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          colorschemes = {
            confirm = function(picker, item)
              picker:close()
              if not item then
                return
              end

              picker.preview.state.colorscheme = nil
              vim.schedule(function()
                if pcall(vim.cmd.colorscheme, item.text) then
                  vim.fn.writefile({ item.text }, file)
                end
              end)
            end,
          },
        },
      },
    },
  },
}
