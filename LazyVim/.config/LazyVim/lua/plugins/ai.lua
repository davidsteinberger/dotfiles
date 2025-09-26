return {
  {
    "NickvanDyke/opencode.nvim",
    dependencies = {
      -- Recommended for better prompt input, and required to use `opencode.nvim`'s embedded terminal — otherwise optional
      { "folke/snacks.nvim", opts = { input = { enabled = true } } },
    },
    config = function()
      -- `opencode.nvim` passes options via a global variable instead of `setup()` for faster startup
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        -- Your configuration, if any — see `lua/opencode/config.lua`
      }

      -- Required for `opts.auto_reload`
      vim.opt.autoread = true

      -- Recommended keymaps
      vim.keymap.set("n", "<leader>ot", function()
        require("opencode").toggle()
      end, { desc = "Toggle opencode" })
      vim.keymap.set("n", "<leader>oA", function()
        require("opencode").ask()
      end, { desc = "Ask opencode" })
      vim.keymap.set("n", "<leader>oa", function()
        require("opencode").ask("@cursor: ")
      end, { desc = "Ask opencode about this" })
      vim.keymap.set("v", "<leader>oa", function()
        require("opencode").ask("@selection: ")
      end, { desc = "Ask opencode about selection" })
      vim.keymap.set("n", "<leader>on", function()
        require("opencode").command("session_new")
      end, { desc = "New opencode session" })
      vim.keymap.set("n", "<leader>oy", function()
        require("opencode").command("messages_copy")
      end, { desc = "Copy last opencode response" })
      vim.keymap.set("n", "<S-C-u>", function()
        require("opencode").command("messages_half_page_up")
      end, { desc = "Messages half page up" })
      vim.keymap.set("n", "<S-C-d>", function()
        require("opencode").command("messages_half_page_down")
      end, { desc = "Messages half page down" })
      vim.keymap.set({ "n", "v" }, "<leader>os", function()
        require("opencode").select()
      end, { desc = "Select opencode prompt" })

      -- Example: keymap for custom prompt
      vim.keymap.set("n", "<leader>oe", function()
        require("opencode").prompt("Explain @cursor and its context")
      end, { desc = "Explain this code" })
    end,
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    enabled = false,
    lazy = false,
    version = false, -- set this if you want to always pull the latest change
    opts = {
      -- add any opts here
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "nvim-tree/nvim-web-devicons", -- or nvim-mini/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
}
