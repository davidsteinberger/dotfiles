return {
  {
    "tpope/vim-dispatch",
    cmd = { "Dispatch", "Make", "Focus", "Start" },
    config = function()
      vim.g.dispatch_no_tmux_make = 1
      vim.g.dispatch_no_tmux_start = 1
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
    "saghen/blink.cmp",
    opts = {
      enabled = function()
        return not vim.tbl_contains({ "typr" }, vim.bo.filetype)
      end,
      -- completion = {
      --   list = {
      --     selection = {
      --       preselect = false,
      --       -- auto_insert = false,
      --     },
      --   },
      -- },
      cmdline = {
        enabled = true,
        keymap = {
          preset = "cmdline",
          ["<Right>"] = { "select_next", "fallback" },
          ["<Left>"] = { "select_prev", "fallback" },
        },
      },
      -- keymap = {
      --   ["<RIGHT>"] = { "select_and_accept", "fallback" },
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
  {
    "nvim-mini/mini.surround",
    opts = {
      mappings = {
        add = "sa", -- Add surrounding in Normal and Visual modes
        delete = "sd", -- Delete surrounding
        find = "sf", -- Find surrounding (to the right)
        find_left = "sF", -- Find surrounding (to the left)
        highlight = "sh", -- Highlight surrounding
        replace = "sr", -- Replace surrounding
        update_n_lines = "sn", -- Update `n_lines`
      },
    },
    keys = function(_, keys)
      return vim.list_extend(keys, {
        { "S", [[:<C-u>lua MiniSurround.add('visual')<CR>]], mode = { "v" } },
      })
    end,
  },
  {
    "folke/which-key.nvim",
    opts = {
      triggers = {
        { "<auto>", mode = "nixsotc" },
        { "s", mode = { "n", "v" } },
      },
      spec = {
        mode = { "n", "v" },
        {
          "gs",
        },
        {
          "gx",
        },
      },
    },
  },
  {
    "nvim-mini/mini.move",
    version = "*",
    opts = {},
    config = function(_, opts)
      vim.schedule(function()
        require("mini.move").setup(opts)
      end)
    end,
  },
  {
    "nvim-mini/mini.operators",
    version = "*",
    event = "VeryLazy",
    opts = {
      replace = { prefix = "cr" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          keys = {
            -- Disable default "gr" mapping for LSP references
            { "gr", false },
            {
              "<leader>gr",
              -- "<cmd>FzfLua lsp_references      jump1=true ignore_current_line=true<cr>",
              function()
                Snacks.picker.lsp_references()
              end,
              desc = "References",
              nowait = true,
            },
          },
        },
      },
    },
  },
}
