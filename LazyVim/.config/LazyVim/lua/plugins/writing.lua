return {
  {
    {
      "williamboman/mason.nvim",
      opts = {
        ensure_installed = {
          "proselint",
          "write-good",
          "alex",
        },
      },
    },
    {
      "nvimtools/none-ls.nvim",
      opts = function(_, opts)
        local nls = require("null-ls")
        local sources = {}
        for _, v in pairs(opts.sources) do
          if v.name ~= "stylua" and v.name ~= "fish" and v.name ~= "shfmt" then
            sources[#sources + 1] = v
          end
        end
        opts.sources = vim.list_extend(sources, {
          nls.builtins.diagnostics.proselint,
          nls.builtins.code_actions.proselint,
          nls.builtins.diagnostics.alex,
          nls.builtins.diagnostics.write_good,
        })
      end,
    },
  },
  {
    "NStefan002/speedtyper.nvim",
    branch = "main",
    cmd = "Speedtyper",
    opts = {},
  },
  {
    "epwalsh/obsidian.nvim",
    -- version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      workspaces = {
        {
          name = "Main",
          path = "~/vaults/Main",
        },
        {
          name = "Work",
          path = "~/vaults/Main/Work",
        },
      },
      notes_subdir = "Zettelkasten",
      attachments = {
        img_folder = "Files",
      },
      templates = {
        subdir = "Templates",
        date_format = "%Y%m%d",
        substitutions = {
          ["date:YYYYMMDD"] = function()
            return os.date("%Y%m%d")
          end,
          ["time:HHmm"] = function()
            return os.date("%H%M")
          end,
          ["date:YYYY-MM-DD"] = function()
            return os.date("%Y-%m-%d")
          end,
        },
      },
      note_id_func = function(title)
        local suffix = ""
        if title ~= nil then
          suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
        else
          for _ = 1, 4 do
            suffix = suffix .. string.char(math.random(65, 90))
          end
        end
        return tostring(os.date("%Y%m%d%H%M")) .. "-" .. suffix
      end,
      disable_frontmatter = true,
      open_app_foreground = true,
      daily_notes = {
        folder = "Journal",
        date_format = "%Y/%m-%B/%Y-%m-%d",
        alias_format = "%Y-%m-%d",
        template = "Daily template.md",
      },
    },
    keys = {
      {
        "<LocalLeader>n",
        ":ObsidianNew ",
        desc = "Obsidian: New Note",
      },
      {
        "<LocalLeader>d",
        "<cmd>ObsidianToday<cr>",
        desc = "Obsidian: Today",
      },
      {
        "<LocalLeader>t",
        "<cmd>ObsidianTemplate<cr>",
        desc = "Obsidian: Template",
      },
      {
        "<LocalLeader>o",
        "<cmd>ObsidianOpen<cr>",
        desc = "Obsidian: open",
      },
      {
        "<LocalLeader>f",
        "<cmd>ObsidianQuickSwitch<cr>",
        desc = "Obsidian: Switch",
      },
      {
        "<LocalLeader>s",
        "<cmd>ObsidianSearch<cr>",
        desc = "Obsidian: Search",
      },
      {
        "<LocalLeader>w",
        ":ObsidianWorkspace ",
        desc = "Obsidian: Workspace",
      },
    },
  },
}
