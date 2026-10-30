
return {
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewFileHistory",
    },
    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diffview: Working Tree" },
      {
        "<leader>gV",
        function()
          Snacks.picker.git_branches({
            all = true,
            confirm = function(picker, item)
              picker:close()
              if not item or not item.branch then
                return
              end

              vim.schedule(function()
                vim.api.nvim_cmd({
                  cmd = "DiffviewOpen",
                  args = { item.branch .. "...HEAD" },
                }, {})
              end)
            end,
          })
        end,
        desc = "Diffview: Compare Branch",
      },
      { "<leader>gF", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: File History" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: Repository History" },
    },
    opts = {
      -- Diffview merges these into its defaults (disable_defaults = false).
      -- Add only a close key: the diff and file panels have none.
      keymaps = {
        view = { { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } } },
        file_panel = { { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } } },
        file_history_panel = { { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } } },
      },
    },
  },
}

