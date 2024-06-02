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

-- delete to blackhole register
map("x", "<BS>", '"_d', DEFAULT_OPTIONS)

-- change word
map("n", "<BS><BS>", '"_diw', DEFAULT_OPTIONS)
map("n", "<BS>w", '"_ciw', DEFAULT_OPTIONS)
map("n", "<BS>p", '"_cw', DEFAULT_OPTIONS)
map("n", "<BS>'", "\"_ci'", DEFAULT_OPTIONS)
map("n", '<BS>"', '"_ci"', DEFAULT_OPTIONS)

-- select word
map("v", "<M-Right>", "e", DEFAULT_OPTIONS)
map("v", "<M-Left>", "b", DEFAULT_OPTIONS)

-- paste and keep the  p register
map("x", "<leader>p", '"_dP', DEFAULT_OPTIONS)

-- copy entire buffer
map("n", "<leader>Y", ":%y+<CR>", DEFAULT_OPTIONS)

-- select from beginnig to end of line
map("n", "<leader>v", "v_og_", DEFAULT_OPTIONS)

-- copy relative path
map("n", "cp", ':let @+=fnamemodify(expand("%"), ":~:.")<CR>', DEFAULT_OPTIONS)
map("n", "cP", ':let @+=expand("%:p")<CR>', DEFAULT_OPTIONS)

-- restore cursor position after joining lines
map("n", "J", "mzJ`z", DEFAULT_OPTIONS)

map("n", "<c-h>", ":TmuxNavigateLeft<cr>", { silent = true, noremap = true })
map("n", "<c-l>", ":TmuxNavigateRight<cr>", { silent = true, noremap = true })
map("n", "<c-j>", ":TmuxNavigateDown<cr>", { silent = true, noremap = true })
map("n", "<c-k>", ":TmuxNavigateUp<cr>", { silent = true, noremap = true })
map("n", "<c-LEFT>", ":TmuxNavigateLeft<cr>", { silent = true, noremap = true })
map("n", "<c-RIGHT>", ":TmuxNavigateRight<cr>", { silent = true, noremap = true })
map("n", "<c-DOWN>", ":TmuxNavigateDown<cr>", { silent = true, noremap = true })
map("n", "<c-UP>", ":TmuxNavigateUp<cr>", { silent = true, noremap = true })

map("i", "<c-c>", "<ESC>", { silent = true, noremap = true })
map({ "n", "i", "v" }, "<m-i>", "<ESC>", { silent = true, noremap = true })
map({ "i", "v" }, "<ESC>", "<ESC>", { silent = true, noremap = true })

-- Resizing panes
-- map("n", "<Left>", ":vertical resize -1<CR>", DEFAULT_OPTIONS)
-- map("n", "<Right>", ":vertical resize +1<CR>", DEFAULT_OPTIONS)
-- map("n", "<Up>", ":resize -1<CR>", DEFAULT_OPTIONS)
-- map("n", "<Down>", ":resize +1<CR>", DEFAULT_OPTIONS)

map("n", "<TAB>", ":BufferLineCycleNext<CR>", DEFAULT_OPTIONS)
map("n", "<S-TAB>", ":BufferLineCyclePrev<CR>", DEFAULT_OPTIONS)
map("n", "<C-f>", "M<C-f>zz", DEFAULT_OPTIONS)
map("n", "<C-u>", "M<C-u>zz", DEFAULT_OPTIONS)
map("n", "<PageDown>", "M<C-d>zz", DEFAULT_OPTIONS)
map("n", "<PageUp>", "M<C-u>zz", DEFAULT_OPTIONS)

vim.g.diagnostics_virtual = true
vim.api.nvim_create_user_command("DiagnosticVirtual", function()
  if vim.g.diagnostics_virtual then
    vim.g.diagnostics_virtual = false
    vim.diagnostic.config({ virtual_text = false })
  else
    vim.g.diagnostics_virtual = true
    vim.diagnostic.config({ virtual_text = true })
  end
end, {})

vim.api.nvim_create_user_command("DarkMode", function(opts)
  DarkMode(opts.args == "true")
end, { nargs = "?" })

vim.api.nvim_create_user_command("LightMode", function()
  LightMode()
end, {})
