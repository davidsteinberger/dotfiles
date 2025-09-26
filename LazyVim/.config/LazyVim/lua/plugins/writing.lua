return {
  {
    {
      "mason-org/mason.nvim",
      opts = {
        ensure_installed = {
          "proselint",
          "write-good",
          "alex",
        },
      },
    },
  },
  {
    "epwalsh/obsidian.nvim",
    enabled = false,
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
      ui = {
        enable = false,
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
  {
    "nvzone/typr",
    dependencies = "nvzone/volt",
    opts = {},
    cmd = { "Typr", "TyprStats" },
  },
}
