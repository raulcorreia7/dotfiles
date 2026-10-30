-- Diffview.nvim: diff/review UI with staging from the file panel.
-- Entry points only; in-diffview keymaps stay upstream's (merged into ours).
local function open(args)
  require("diffview").open(args or {})
end

local function file_history(args)
  require("diffview").file_history(nil, args or {})
end

local function close()
  require("diffview").close()
end

return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      { "<leader>gv", function() open() end, desc = "Diffview: Working Tree" },
      {
        "<leader>gV",
        function()
          Snacks.picker.git_branches({
            all = true,
            confirm = function(picker, item)
              picker:close()
              if not item or not item.branch then return end
              vim.schedule(function()
                -- `A...B` needs a merge base; unrelated histories (snapshot or
                -- orphan branches) make diffview fail with "Failed to parse
                -- rev". Use a direct `A..B` diff instead, which always works.
                open({ item.branch .. "..HEAD" })
              end)
            end,
          })
        end,
        desc = "Diffview: Compare Branch",
      },
      {
        "<leader>gF",
        function()
          local file = vim.api.nvim_buf_get_name(0)
          if file == "" then
            file_history({})
          else
            file_history({ file })
          end
        end,
        desc = "Diffview: File History",
      },
      { "<leader>gH", function() file_history({}) end, desc = "Diffview: Repository History" },
    },
    opts = {
      -- Less chrome in the diff view (user: "less is more").
      show_help_hints = false,
      -- Diffview merges these into its defaults (disable_defaults = false).
      -- Add only a close key: the diff and file panels have none.
      keymaps = {
        view = { { "n", "q", close, { desc = "Close diffview" } } },
        file_panel = { { "n", "q", close, { desc = "Close diffview" } } },
        file_history_panel = { { "n", "q", close, { desc = "Close diffview" } } },
      },
    },
  },
}
