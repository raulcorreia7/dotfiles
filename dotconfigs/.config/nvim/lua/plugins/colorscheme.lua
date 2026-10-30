-- Picked colorscheme is persisted to stdpath("data")/theme and re-applied at
-- startup. Both pickers can write it: fzf-lua owns <leader>uC, snacks is kept
-- working in case the picker extra changes.
local file = vim.fn.stdpath("data") .. "/theme"

local function saved()
  local name = vim.fn.filereadable(file) == 1 and vim.fn.readfile(file)[1] or nil
  return name and name ~= "" and name or nil
end

local function save(name)
  if name and name ~= "" then
    vim.fn.writefile({ name }, file)
  end
end

-- Persist only after the colorscheme actually loaded, so a broken name never
-- becomes the startup choice.
local function apply(name)
  if name and name ~= "" and pcall(vim.cmd.colorscheme, name) then
    save(name)
  end
end

return {
  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      -- NOTE: opts here are the plugin spec opts, not LazyVim's defaults, so
      -- opts.colorscheme is usually nil and must fall back explicitly.
      local fallback = opts.colorscheme or "tokyonight"

      opts.colorscheme = function()
        local name = saved()
        if name and pcall(vim.cmd.colorscheme, name) then
          return
        end

        if type(fallback) == "function" then
          fallback()
        else
          vim.cmd.colorscheme(fallback)
        end
      end
    end,
  },
  {
    "ibhagwan/fzf-lua",
    optional = true,
    opts = function(_, opts)
      -- fzf-lua provider options are top-level keys, not under `defaults`:
      -- `defaults.colorschemes.actions` is merged as a nested table and ignored.
      opts.colorschemes = vim.tbl_deep_extend("force", opts.colorschemes or {}, {
        actions = {
          ["enter"] = function(selected)
            apply(selected and selected[1] and selected[1]:match("^[^:]+"))
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
                apply(item.text)
              end)
            end,
          },
        },
      },
    },
  },
}

