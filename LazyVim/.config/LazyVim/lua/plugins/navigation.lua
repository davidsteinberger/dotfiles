return {
  {
    "christoomey/vim-tmux-navigator",
  },
  {
    "max397574/better-escape.nvim",
    config = function()
      require("better_escape").setup()
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
    vscode = false,
    opts = {
      modes = {
        search = { enabled = false },
      },
    },
    keys = {
      { "S", false, mode = { "v", "x" } },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        mappings = {
          i = {
            ["<c-q>"] = function(...)
              local actions = require("telescope.actions")
              -- return require("telescope.actions").send_selected_to_qflist(...)
              actions.smart_send_to_qflist(...)
              actions.open_qflist(...)
            end,
          },
        },
      },
    },
  },
  {
    "nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.mapping = vim.tbl_deep_extend("force", opts.mapping, {
        ["<CR>"] = cmp.mapping({
          i = function(fallback)
            if cmp.visible() and cmp.get_active_entry() then
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
            else
              fallback()
            end
          end,
          s = cmp.mapping.confirm({ select = true }),
          c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
        }),
      })
    end,
  },
  {
    "nvim-treesitter",
    opts = {
      incremental_selection = {
        enable = true,
        keymaps = {
          node_incremental = "v",
          node_decremental = "V",
          scope_incremental = "<M-v>",
        },
      },
    },
  },
  {
    "echasnovski/mini.surround",
    keys = function(_, keys)
      return vim.list_extend(keys, {
        { "S", [[:<C-u>lua MiniSurround.add('visual')<CR>]], mode = { "v" } },
      })
    end,
  },
  {
    "echasnovski/mini.animate",
    opts = {
      open = {
        enable = false,
      },
      close = {
        enable = false,
      },
    },
  },
  {
    "tpope/vim-rsi",
  },
}
