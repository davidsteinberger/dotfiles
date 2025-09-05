-- conditionally map <cr> to flash
vim.keymap.set("n", "<cr>", function()
  local win_type = vim.fn.win_gettype()
  return vim.bo.buftype == "" and win_type == "" and "<cmd>lua require('flash').jump()<cr>" or "<cr>"
end, { noremap = true, expr = true })

return {
  {
    "christoomey/vim-tmux-navigator",
  },
  {
    "s1n7ax/nvim-window-picker",
    name = "window-picker",
    event = "VeryLazy",
    version = "2.*",
    config = function()
      require("window-picker").setup()
    end,
  },
  {
    "akinsho/bufferline.nvim",
    keys = {
      { "<leader>bh", "<cmd>BufferLineCloseLeft<cr>", desc = "Close all to the left" },
      { "<leader>bl", "<cmd>BufferLineCloseRight<cr>", desc = "Close all to the right" },
    },
  },
  {
    "folke/flash.nvim",
    keys = {
      { "S", false, mode = { "v", "x" } },
      { "s", false },
      {
        "ss",
        mode = { "n", "x", "o" },
        function()
          return require("flash").jump()
        end,
        desc = "Flash",
      },
    },
  },
  {
    "tpope/vim-rsi",
  },
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        formatters = {
          file = {
            truncate = 100,
          },
        },
      },
    },
  },
}
