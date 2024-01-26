return {
  {
    "L3MON4D3/LuaSnip",
    keys = function()
      return {
        {
          "<C-L>",
          function()
            require("luasnip").jump(1)
          end,
          mode = { "i", "s" },
        },
        {
          "<C-J>",
          function()
            require("luasnip").jump(-1)
          end,
          mode = { "i", "s" },
        },
      }
    end,
    opts = function()
      local luasnip = require("luasnip")
      luasnip.filetype_extend("javascript", { "html" })
      luasnip.filetype_extend("javascriptreact", { "html" })
      luasnip.filetype_extend("typescriptreact", { "html" })
      require("luasnip/loaders/from_vscode").lazy_load()
    end,
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = {
          enabled = true,
          auto_refresh = true,
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = "<M-l>",
            accept_word = false,
            accept_line = false,
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
      })

      -- hide copilot suggestions when cmp menu is open
      -- to prevent odd behavior/garbled up suggestions
      -- local cmp_status_ok, cmp = pcall(require, "cmp")
      -- if cmp_status_ok then
      --   cmp.event:on("menu_opened", function()
      --     vim.b.copilot_suggestion_hidden = true
      --   end)
      --
      --   cmp.event:on("menu_closed", function()
      --     vim.b.copilot_suggestion_hidden = false
      --   end)
      -- end
    end,
  },
  {
    "nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-emoji",
    },
    opts = function(_, opts)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local luasnip = require("luasnip")
      local suggestions = require("copilot.suggestion")
      local cmp = require("cmp")
      table.insert(opts.sources, { name = "emoji" })
      opts.experimental = {
        ghost_text = false,
      }
      opts.mapping = vim.tbl_deep_extend("force", opts.mapping, {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if suggestions.is_visible() then
            return suggestions.accept()
          elseif cmp.visible() then
            local entry = cmp.get_selected_entry()
            if not entry then
              cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
            else
              cmp.confirm()
            end
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            local entry = cmp.get_selected_entry()
            if not entry then
              cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
            else
              cmp.confirm()
            end
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<Down>"] = cmp.mapping.select_next_item(),
        ["<Up>"] = cmp.mapping.select_prev_item(),
        ["<CR>"] = cmp.mapping({
          i = function(fallback)
            if cmp.visible() and cmp.get_active_entry() then
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = false })
            else
              fallback()
            end
          end,
          s = cmp.mapping.confirm({ select = true }),
          c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = false }),
        }),
      })
    end,
  },
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
    "gbprod/yanky.nvim",
    keys = {
      { "<c-p>", "<Plug>(YankyPreviousEntry)", desc = "Cycle backward through yank history" },
      { "<c-n>", "<Plug>(YankyNextEntry)", desc = "Cycle forward through yank history" },
    },
  },
  {
    "monaqa/dial.nvim",
    -- stylua: ignore
    keys = {
      { "<C-a>", function() return require("dial.map").inc_normal() end, expr = true, desc = "Increment" },
      { "<C-x>", function() return require("dial.map").dec_normal() end, expr = true, desc = "Decrement" },
    },
    config = function()
      local augend = require("dial.augend")
      require("dial.config").augends:register_group({
        default = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.date.alias["%Y/%m/%d"],
          augend.date.alias["%Y-%m-%d"],
          augend.constant.alias.bool,
          augend.semver.alias.semver,
          augend.constant.new({ elements = { "let", "const" } }),
        },
      })
    end,
  },
}
