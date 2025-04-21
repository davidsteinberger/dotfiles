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
        "<M-s>",
        mode = { "n", "x", "o" },
        function()
          if string.sub(vim.api.nvim_buf_get_name(0), 1, 8) ~= "fugitive" then
            require("flash").jump()
            return
          end
        end,
        desc = "Flash",
      },
    },
  },
  {
    "tpope/vim-rsi",
  },
  {
    "ibhagwan/fzf-lua",
    optional = true,
    keys = {
      {
        "<leader>fp",
        LazyVim.pick("files", { cwd = require("lazy.core.config").options.root }),
        desc = "Find Plugin File",
      },
      {
        "<leader>sp",
        function()
          local dirs = { "~/dotfiles/LazyVim/.config/LazyVim/lua/plugins" }
          require("fzf-lua").live_grep({
            filespec = "-- " .. table.concat(vim.tbl_values(dirs), " "),
            search = "/",
            formatter = "path.filename_first",
          })
        end,
        desc = "Search Plugin Spec",
      },
    },
  },
}
