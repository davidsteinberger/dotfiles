local map = vim.api.nvim_set_keymap
DEFAULT_OPTIONS = { noremap = true, silent = true }
EXPR_OPTIONS = { noremap = true, expr = true, silent = true }

vim.opt.relativenumber = true

map("n", "<Space>", "<NOP>", DEFAULT_OPTIONS)
vim.g.mapleader = " "

-- Use <leader>d (or ,dd or ,dj or 20,dd) to delete a line without adding it to the
map("n", "<leader>d", '"_d', DEFAULT_OPTIONS)
map("v", "<leader>d", '"_d', DEFAULT_OPTIONS)

-- apply the same to ,x
map("n", "<leader>x", '"_x', DEFAULT_OPTIONS)
map("v", "<leader>x", '"_x', DEFAULT_OPTIONS)

-- paste and keep the  p register
map("x", "<leader>p", '"_dP', DEFAULT_OPTIONS)

-- copy the current word or visually selected text to the clipboard
map("n", "<leader>y", '"+yiw', DEFAULT_OPTIONS)
map("v", "<leader>y", '"+y', DEFAULT_OPTIONS)

-- copy entire buffer
map("n", "<leader>Y", ':%y+<CR>', DEFAULT_OPTIONS)

-- select from beginnig to end of line
map("n", "<leader>v", "v_o$", DEFAULT_OPTIONS)

-- copy relative path
map("n", "cp", ':let @+=fnamemodify(expand("%"), ":~:.")<CR>', DEFAULT_OPTIONS)

-- Remap colon
map("n", "ö", ":", { noremap = true })
-- map("n", ";;", ";", { noremap = true })
map("n", ";", ":", { noremap = true })
map("n", ":", ";", { noremap = true })
map("v", ";", ":", { noremap = true })
map("v", ":", ";", { noremap = true })

--Save
map("i", "<C-s>", "<C-o>:up<CR>", { noremap = true })
map("n", "<C-s>", ":up<CR>", { noremap = true })

-- ESC terminal
map("t", "<Esc>", "<C-\\><C-n>", DEFAULT_OPTIONS)

-- Deal with visual line wraps
map("n", "k", "v:count == 0 ? 'gk' : 'k'", EXPR_OPTIONS)
map("n", "j", "v:count == 0 ? 'gj' : 'j'", EXPR_OPTIONS)

-- Tab switch buffer
map("n", "<TAB>", ":bnext<CR>", DEFAULT_OPTIONS)
map("n", "<S-TAB>", ":bprevious<CR>", DEFAULT_OPTIONS)

-- Cancel search highlighting with ESC
map("n", "<ESC>", ":nohlsearch<Bar>:echo<CR>", DEFAULT_OPTIONS)

-- Resizing panes
map("n", "<Left>", ":vertical resize -1<CR>", DEFAULT_OPTIONS)
map("n", "<Right>", ":vertical resize +1<CR>", DEFAULT_OPTIONS)
map("n", "<Up>", ":resize -1<CR>", DEFAULT_OPTIONS)
map("n", "<Down>", ":resize +1<CR>", DEFAULT_OPTIONS)

-- Move selected line / block of text in visual mode
map("x", "K", ":move '<-2<CR>gv-gv", DEFAULT_OPTIONS)
map("x", "J", ":move '>+1<CR>gv-gv", DEFAULT_OPTIONS)

map("n", "<leader>9", ":set notimeout<cr>", DEFAULT_OPTIONS)
map("n", "<leader>)", ":set timeout<cr>", DEFAULT_OPTIONS)

map("n", "<C-c>", ":compiler tsc | setlocal makeprg=yarn\\ tsc\\ --noEmit | make | copen<CR>", { noremap = true })

-- theme
vim.g.gruvbox_baby_telescope_theme = 1
vim.g.gruvbox_baby_background_color = 'dark'
vim.g.gruvbox_baby_use_original_palette = false

-- lvim
lvim.format_on_save = true
lvim.log.level = "warn"
lvim.colorscheme = "gruvbox-baby"
lvim.leader = "space"
lvim.builtin.which_key.setup.plugins.registers = true
lvim.builtin.terminal.active = true
lvim.builtin.terminal.start_in_insert = true
lvim.keys.normal_mode["<C-t>"] = ":ToggleTerm<cr>"
lvim.builtin.telescope.defaults.file_ignore_patterns = { ".yarn", "node_modules" }
lvim.builtin.which_key.mappings["lA"] = {
  "<cmd>TSLspImportAll<CR>", "Import All"
}
lvim.builtin.which_key.mappings["t"] = {
  name = "+Trouble",
  r = { "<cmd>Trouble lsp_references<cr>", "References" },
  f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
  d = { "<cmd>Trouble document_diagnostics<cr>", "Diagnostics" },
  q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
  l = { "<cmd>Trouble loclist<cr>", "LocationList" },
  w = { "<cmd>Trouble workspace_diagnostics<cr>", "Diagnostics" },
  t = { "<cmd>DiagnosticToggle<cr>", "Toggle Diagnostics" },
  v = { "<cmd>DiagnosticVirtual<cr>", "Toggle Diagnostics Virtual" },
}

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "c",
  "javascript",
  "json",
  "lua",
  "python",
  "typescript",
  "css",
  "rust",
  "java",
  "yaml",
}

lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true
lvim.builtin.cmp.formatting.max_width = 50

-- generic LSP settings
lvim.lsp.diagnostics.virtual_text = true

-- Additional Plugins
lvim.plugins = {
  {
    'rmagatti/auto-session',
    config = function()
      require("auto-session").setup {
        log_level = "error",
        auto_session_suppress_dirs = { "~/", "~/Downloads", "/" },
      }
    end
  },
  {
    "christoomey/vim-tmux-navigator"
  },
  {
    "max397574/better-escape.nvim",
    config = function()
      require("better_escape").setup()
    end,
  },
  {
    "catppuccin/nvim",
    as = "catppuccin",
    config = function()
      -- vim.g.catppuccin_flavour = "macchiato" -- latte, frappe, macchiato, mocha
      vim.g.catppuccin_flavour = "mocha"
    end
  },
  { "luisiacc/gruvbox-baby" },
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
  {
    "folke/trouble.nvim",
    cmd = "TroubleToggle",
  },
  {
    "tpope/vim-fugitive",
    cmd = {
      "G",
      "Git",
      "Gdiffsplit",
      "Gread",
      "Gwrite",
      "Ggrep",
      "GMove",
      "GDelete",
      "GBrowse",
      "GRemove",
      "GRename",
      "Glgrep",
      "Gedit"
    },
    ft = { "fugitive" }
  },
  {
    "tpope/vim-surround",
    -- keys = { "c", "d", "y", "s" }
  },
  {
    "sidebar-nvim/sidebar.nvim",
    config = function()
      require("sidebar-nvim").setup({ open = false, side = "right" })
    end
  },
  {
    "phaazon/hop.nvim",
    event = "BufRead",
    config = function()
      require("hop").setup()
      vim.api.nvim_set_keymap("n", "s", ";HopChar2<cr>", { silent = true })
      vim.api.nvim_set_keymap("n", "S", ";HopWord<cr>", { silent = true })
    end,
  },
  {
    "github/copilot.vim"
  },
  {
    "iamcco/markdown-preview.nvim",
    run = function() vim.fn["mkdp#util#install"]() end,
  }
}

--markdown
vim.g.mkdp_auto_close = 0

-- copilot
vim.g.copilot_no_tab_map = true
vim.g.copilot_assume_mapped = true
map("i", "<C-H>", 'copilot#Accept("<CR>")', EXPR_OPTIONS)
map("i", "<C-J>", 'copilot#Previous()', EXPR_OPTIONS)
map("i", "<C-K>", 'copilot#Next()', EXPR_OPTIONS)
local cmp = require "cmp"
-- lvim.builtin.cmp.mapping = cmp.mapping.preset.insert({
--   ["<C-j>"] = nil
-- })
lvim.builtin.cmp.mapping["<C-H>"] = function(fallback)
  cmp.mapping.abort()
  local copilot_keys = vim.fn["copilot#Accept"]()
  if copilot_keys ~= "" then
    vim.api.nvim_feedkeys(copilot_keys, "i", true)
  else
    fallback()
  end
end

-- null-ls
local null_ls = require("null-ls")

vim.api.nvim_create_user_command("NullLsToggle", function()
  require("null-ls").toggle({})
end, {})

vim.g.dianostics_virtual = true
vim.api.nvim_create_user_command("DiagnosticVirtual", function()
  if vim.g.dianostics_virtual then
    vim.g.dianostics_virtual = false
    vim.diagnostic.config({ virtual_text = false })
  else
    vim.g.dianostics_virtual = true
    vim.diagnostic.config({ virtual_text = true })
  end
end, {})

vim.g.diagnostics_active = true
vim.api.nvim_create_user_command("DiagnosticToggle", function()
  if vim.g.diagnostics_active then
    vim.g.diagnostics_active = false
    vim.diagnostic.hide()
  else
    vim.g.diagnostics_active = true
    vim.diagnostic.show()
  end
end, {})

local command_resolver = require("null-ls.helpers.command_resolver")
local is_pnp = vim.fn.findfile('.pnp.cjs', '.')

local with_yarn_pnp = function(source)
  return source.with({
    dynamic_command = is_pnp and command_resolver.from_yarn_pnp() or nil,
  })
end

local sources = {
  with_yarn_pnp(null_ls.builtins.formatting.prettier),
  with_yarn_pnp(null_ls.builtins.diagnostics.eslint),
  with_yarn_pnp(null_ls.builtins.code_actions.eslint)
}

null_ls.register({ sources = sources })

-- experimental

-- require("lvim.lsp.manager").setup('eslint')
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "tailwindcss" })
require("lvim.lsp.manager").setup("tailwindcss", {
  settings = {
    tailwindCSS = {
      experimental = {
        classRegex = {
          'tw`([^`]*)',
          'tw="([^"]*)',
          'tw={"([^"}]*)',
          'tw\\.\\w+`([^`]*)',
          'tw\\(.*?\\)`([^`]*)',
        },
      },
    },
  },

})

lvim.builtin.dap.active = true
local dap = require("dap")

dap.adapters.delve = {
  type = 'server',
  port = '${port}',
  executable = {
    command = 'dlv',
    args = { 'dap', '-l', '127.0.0.1:${port}' },
  }
}
-- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
dap.configurations.go = {
  {
    type = "delve",
    name = "Debug",
    request = "launch",
    program = "${file}"
  },
  {
    type = "delve",
    name = "Debug test", -- configuration for debugging test files
    request = "launch",
    mode = "test",
    program = "${file}"
  },
  -- works with go.mod packages and sub packages
  {
    type = "delve",
    name = "Debug test (go.mod)",
    request = "launch",
    mode = "test",
    program = "./${relativeFileDirname}"
  }
}
