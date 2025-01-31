return {
  {
    "tpope/vim-dispatch",
    cmd = { "Dispatch", "Make", "Focus", "Start" },
    config = function()
      vim.g.dispatch_no_tmux_make = 1
    end,
  },
  {
    "piersolenski/wtf.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    opts = {},
    keys = {
      {
        "gw",
        mode = { "n", "x" },
        function()
          require("wtf").ai()
        end,
        desc = "Debug diagnostic with AI",
      },
      {
        mode = { "n" },
        "gW",
        function()
          require("wtf").search()
        end,
        desc = "Search diagnostic with Google",
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
    "razak17/tailwind-fold.nvim",
    opts = {},
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = { "html", "svelte", "astro", "vue", "typescriptreact", "php", "blade", "typescriptreact" },
  },
  {
    "saghen/blink.cmp",
    opts = {
      enabled = function()
        return not vim.tbl_contains({ "typr" }, vim.bo.filetype) and vim.bo.buftype ~= "prompt"
      end,
      completion = {
        list = {
          selection = {
            preselect = false,
            auto_insert = false,
          },
        },
      },
      -- keymap = {
      --   -- preset = "super-tab",
      --   ["<Tab>"] = {
      --     LazyVim.cmp.map({ "ai_accept", "snippet_forward" }),
      --     "fallback",
      --   },
      -- },
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      zen = {
        win = {
          backdrop = {
            transparent = false,
          },
        },
      },
    },
  },
}
