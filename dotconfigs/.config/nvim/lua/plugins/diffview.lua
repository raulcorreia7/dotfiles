
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
      keymaps = {
        view = { q = "<cmd>DiffviewClose<cr>" },
        file_panel = { q = "<cmd>DiffviewClose<cr>" },
        file_history_panel = { q = "<cmd>DiffviewClose<cr>" },
      },
    },
  },
}

