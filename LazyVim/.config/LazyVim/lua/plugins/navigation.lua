return {
  {
    "christoomey/vim-tmux-navigator",
  },
  {
    "max397574/better-escape.nvim",
    config = function()
      require("better_escape").setup({
        mappings = {
          i = {
            j = {
              v = "<Esc>",
            },
            v = {
              j = "<Esc>",
            },
          },
        },
      })
    end,
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
    -- vscode = false,
    -- opts = {
    --   modes = {
    --     search = { enabled = false },
    --     char = { enabled = false },
    --   },
    -- },
    keys = {
      { "S", false, mode = { "v", "x" } },
      {
        "s",
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
  -- {
  --   "nvim-telescope/telescope.nvim",
  --   dependencies = {
  --     "nvim-telescope/telescope-fzf-native.nvim",
  --     build = "make",
  --     config = function()
  --       require("telescope").load_extension("fzf")
  --     end,
  --   },
  --   opts = {
  --     defaults = {
  --       mappings = {
  --         i = {
  --           ["<c-q>"] = function(...)
  --             local actions = require("telescope.actions")
  --             -- return require("telescope.actions").send_selected_to_qflist(...)
  --             actions.smart_send_to_qflist(...)
  --             actions.open_qflist(...)
  --           end,
  --         },
  --       },
  --     },
  --   },
  -- },
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
