-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

DEFAULT_OPTIONS = { noremap = true, silent = true }
local function map(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  -- do not create the keymap if a lazy keys handler exists
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    if opts.remap and not vim.g.vscode then
      opts.remap = nil
    end
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

-- Use <leader>d to delete without adding it to the default register
map("v", "<leader>d", '"_d', DEFAULT_OPTIONS)

-- apply the same to ,x
map("v", "<leader>x", '"_x', DEFAULT_OPTIONS)

-- paste and keep the  p register
map("x", "<leader>p", '"_dP', DEFAULT_OPTIONS)

-- copy the current word or visually selected text to the clipboard
map("n", "<leader>y", '"+yiw', DEFAULT_OPTIONS)
map("v", "<leader>y", '"+y', DEFAULT_OPTIONS)

-- copy entire buffer
map("n", "<leader>Y", ":%y+<CR>", DEFAULT_OPTIONS)

-- select from beginnig to end of line
map("n", "<leader>v", "v_o$", DEFAULT_OPTIONS)

-- copy relative path
map("n", "cp", ':let @+=fnamemodify(expand("%"), ":~:.")<CR>', DEFAULT_OPTIONS)

map("n", "<c-h>", ":TmuxNavigateLeft<cr>", { silent = true, noremap = true })
map("n", "<c-l>", ":TmuxNavigateRight<cr>", { silent = true, noremap = true })
map("n", "<c-j>", ":TmuxNavigateDown<cr>", { silent = true, noremap = true })
map("n", "<c-k>", ":TmuxNavigateUp<cr>", { silent = true, noremap = true })

-- Resizing panes
map("n", "<Left>", ":vertical resize -1<CR>", DEFAULT_OPTIONS)
map("n", "<Right>", ":vertical resize +1<CR>", DEFAULT_OPTIONS)
map("n", "<Up>", ":resize -1<CR>", DEFAULT_OPTIONS)
map("n", "<Down>", ":resize +1<CR>", DEFAULT_OPTIONS)

map("n", "<TAB>", ":bnext<CR>", DEFAULT_OPTIONS)
map("n", "<S-TAB>", ":bprevious<CR>", DEFAULT_OPTIONS)

map("n", "<C-d>", "<C-d>zz", DEFAULT_OPTIONS)
map("n", "<C-u>", "<C-u>zz", DEFAULT_OPTIONS)

vim.g.diagnostics_virtual = false
vim.api.nvim_create_user_command("DiagnosticVirtual", function()
  if vim.g.diagnostics_virtual then
    vim.g.diagnostics_virtual = false
    vim.diagnostic.config({ virtual_text = false })
  else
    vim.g.diagnostics_virtual = true
    vim.diagnostic.config({ virtual_text = true })
  end
end, {})

vim.g.transparent = true
vim.api.nvim_create_user_command("TransparentToggle", function()
  if vim.g.transparent then
    vim.g.transparent = false
    require("kanagawa").setup({ theme = "lotus", transparent = false })
    vim.api.nvim_set_option("background", "light")
  else
    vim.g.transparent = true
    require("kanagawa").setup({ theme = "wave", transparent = true })
    vim.api.nvim_set_option("background", "dark")
  end
end, {})
