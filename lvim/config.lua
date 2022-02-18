local map = vim.api.nvim_set_keymap
DEFAULT_OPTIONS = {noremap = true, silent = true}
EXPR_OPTIONS = {noremap = true, expr = true, silent = true}

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

" copy the current word or visually selected text to the clipboard
nnoremap <leader>y "+yiw
vnoremap <leader>y "+y

" copy entire buffer
nnoremap <leader>Y :%y+<CR>

nnoremap <leader>d "_d
vnoremap <leader>d "_d

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
map("n", "ö", ":", {noremap = true})
map("n", "<leader>ö", "q:", {noremap = true})

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
lvim.colorscheme = "gruvbox"
lvim.leader = "space"
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"

lvim.builtin.telescope.defaults.file_ignore_patterns = { ".yarn", "node_modules"}
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
}

lvim.builtin.dashboard.active = true
lvim.builtin.notify.active = true
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.show_icons.git = 0

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
  {"morhetz/gruvbox"},
  {"jose-elias-alvarez/nvim-lsp-ts-utils"},
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "BufRead",
    setup = function()
      vim.g.indentLine_enabled = 1
      vim.g.indent_blankline_char = "▏"
      vim.g.indent_blankline_filetype_exclude = {"help", "terminal", "dashboard"}
      vim.g.indent_blankline_buftype_exclude = {"terminal"}
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
    ft = {"fugitive"}
  },
  {
    "tpope/vim-surround",
  },
  {
    "sidebar-nvim/sidebar.nvim",
    config = function()
      require("sidebar-nvim").setup({ open = false, side = "right"})
    end
  }
}

-- generic LSP settings
lvim.lsp.diagnostics.virtual_text = false

-- null-ls
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  {
    command = "prettier",
    extra_args = { "--print-with", "100" },
    filetypes = { "typescript", "typescriptreact" },
  },
}

local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
  {
    command = "eslint_d",
  },
}

-- local null_ls = require("null-ls")
-- null_ls.setup({
--     debug = true
-- })


-- nvim-lsp-ts-utils
local lspconfig = require("lspconfig")
lspconfig.tsserver.setup({
    -- Needed for inlayHints. Merge this table with your settings or copy
    -- it from the source if you want to add your own init_options.
    init_options = require("nvim-lsp-ts-utils").init_options,
    --
    on_attach = function(client, bufnr)
        local ts_utils = require("nvim-lsp-ts-utils")
 
        -- disable tsserver formatting
        client.resolved_capabilities.document_formatting = false

        -- defaults
        ts_utils.setup({
            debug = false,
            disable_commands = false,
            enable_import_on_completion = false,

            -- import all
            import_all_timeout = 5000, -- ms
            -- lower numbers = higher priority
            import_all_priorities = {
                same_file = 1, -- add to existing import statement
                local_files = 2, -- git files or files with relative path markers
                buffer_content = 3, -- loaded buffer content
                buffers = 4, -- loaded buffer names
            },
            import_all_scan_buffers = 100,
            import_all_select_source = false,
            -- if false will avoid organizing imports
            always_organize_imports = true,

            -- filter diagnostics
            filter_out_diagnostics_by_severity = {},
            filter_out_diagnostics_by_code = {},

            -- inlay hints
            auto_inlay_hints = true,
            inlay_hints_highlight = "Comment",
            inlay_hints_priority = 200, -- priority of the hint extmarks
            inlay_hints_throttle = 150, -- throttle the inlay hint request
            inlay_hints_format = { -- format options for individual hint kind
                Type = {},
                Parameter = {},
                Enum = {},
                -- Example format customization for `Type` kind:
                -- Type = {
                --     highlight = "Comment",
                --     text = function(text)
                --         return "->" .. text:sub(2)
                --     end,
                -- },
            },

            -- update imports on file move
            update_imports_on_move = true,
            require_confirmation_on_move = true,
            watch_dir = nil,
        })

        -- required to fix code action ranges and filter diagnostics
        ts_utils.setup_client(client)

        -- no default maps, so you may want to define some here
        local opts = { silent = true }
        vim.api.nvim_buf_set_keymap(bufnr, "n", "gs", ":TSLspOrganize<CR>", opts)
        vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", ":TSLspRenameFile<CR>", opts)
        vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", ":TSLspImportAll<CR>", opts)
    end,
})
