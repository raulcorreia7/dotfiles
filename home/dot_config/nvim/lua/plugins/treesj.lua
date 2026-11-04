return {
  {
    "Wansmer/treesj",
    cmd = { "TSJToggle", "TSJSplit", "TSJJoin" },
    keys = {
      { "<leader>cJ", "<cmd>TSJToggle<cr>", desc = "Split / Join Code" },
    },
    opts = {
      use_default_keymaps = false,
    },
  },
}
