local map = vim.api.nvim_set_keymap
DEFAULT_OPTIONS = { noremap = true, silent = true }
EXPR_OPTIONS = { noremap = true, expr = true, silent = true }

vim.cmd([[
" Use <leader>d (or ,dd or ,dj or 20,dd) to delete a line without adding it to the
" yanked stack (also, in visual mode)
nnoremap <silent> <leader>d "_d
vnoremap <silent> <leader>d "_d
" apply the same to ,x
nnoremap <silent> <leader>x "_x
vnoremap <silent> <leader>x "_x

" paste and keep the  p register
xnoremap <leader>p "_dP

" turn off reference hightlight
" autocmd FileType * hi! link LspReferenceText 0

" copy the current word or visually selected text to the clipboard
autocmd FileType * nnoremap <buffer> <nowait> <leader>y "+yiw
vnoremap <leader>y "+y

" copy entire buffer
autocmd FileType * nnoremap <leader>Y :%y+<CR>

nnoremap <leader>d "_d
vnoremap <leader>d "_d

" copy relative path
nnoremap cp :let @+=fnamemodify(expand("%"), ":~:.")<CR>

function!   QuickFixOpenAll()
    if empty(getqflist())
        return
    endif
    let s:prev_val = ""
    for d in getqflist()
        let s:curr_val = bufname(d.bufnr)
        if (s:curr_val != s:prev_val)
            exec "edit " . s:curr_val
        endif
        let s:prev_val = s:curr_val
    endfor
endfunction
command! QuickFixOpenAll         call QuickFixOpenAll()
]])

vim.opt.relativenumber = true

map("n", "<Space>", "<NOP>", DEFAULT_OPTIONS)
vim.g.mapleader = " "

-- Remap colon
map("n", "ö", ":", { noremap = true })
map("n", "<leader>ö", "q:", { noremap = true })
map("v", "öö", "<ESC>", DEFAULT_OPTIONS);
map("n", "ä", ":nohlsearch<CR>", DEFAULT_OPTIONS);

--Save
map("i", "<C-s>", "<C-o>:w<cr>", DEFAULT_OPTIONS)
map("n", "<C-s>", ":w<cr>", DEFAULT_OPTIONS)

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

-- lvim
lvim.log.level = "warn"
lvim.format_on_save = true
vim.g.gruvbox_baby_telescope_theme = 1
vim.g.gruvbox_baby_background_color = 'dark'
vim.g.gruvbox_baby_use_original_palette = false
lvim.colorscheme = "gruvbox-baby"
lvim.leader = "space"
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"

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

lvim.builtin.notify.active = true
lvim.builtin.terminal.active = true

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

-- Additional Plugins
lvim.plugins = {
  { 'folke/tokyonight.nvim' },
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
    "lukas-reineke/indent-blankline.nvim",
    event = "BufRead",
    setup = function()
      vim.g.indentLine_enabled = 1
      vim.g.indent_blankline_char = "▏"
      vim.g.indent_blankline_filetype_exclude = { "help", "terminal", "dashboard" }
      vim.g.indent_blankline_buftype_exclude = { "terminal" }
      vim.g.indent_blankline_show_trailing_blankline_indent = false
      vim.g.indent_blankline_show_first_indent_level = false
    end
  },
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
    keys = { "c", "d", "y" }
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
      vim.api.nvim_set_keymap("n", "s", ":HopChar2<cr>", { silent = true })
      vim.api.nvim_set_keymap("n", "S", ":HopWord<cr>", { silent = true })
    end,
  },
  {
    "github/copilot.vim"
  },
}

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

lvim.builtin.cmp.formatting.max_width = 50

-- generic LSP settings
lvim.lsp.diagnostics.virtual_text = true

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
  -- with_yarn_pnp(null_ls.builtins.diagnostics.eslint),
  -- with_yarn_pnp(null_ls.builtins.code_actions.eslint)
}

null_ls.register({ sources = sources })

require("lvim.lsp.manager").setup('eslint')
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
