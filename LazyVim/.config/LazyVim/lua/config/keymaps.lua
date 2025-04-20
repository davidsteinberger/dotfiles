-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

DEFAULT_OPTIONS = { noremap = true, silent = true }
local map = vim.keymap.set

-- delete to blackhole register
map("x", "<BS>", '"_d', DEFAULT_OPTIONS)

-- change word
map("n", "<BS><BS>", '"_diw', DEFAULT_OPTIONS)
map("n", "<BS>w", '"_ciw', DEFAULT_OPTIONS)
map("n", "<BS>p", '"_cw', DEFAULT_OPTIONS)
map("n", "<BS>'", "\"_ci'", DEFAULT_OPTIONS)
map("n", '<BS>"', '"_ci"', DEFAULT_OPTIONS)

-- paste and keep the  p register
map("x", "<leader>pp", '"_dP', DEFAULT_OPTIONS)

-- copy entire buffer
map("n", "<leader>Y", ":%y+<CR>", DEFAULT_OPTIONS)

-- select from beginnig to end of line
map("n", "<leader>v", "v_og_", DEFAULT_OPTIONS)

-- copy relative path
map("n", "cp", ':let @+=fnamemodify(expand("%"), ":~:.")<CR>', DEFAULT_OPTIONS)
map("n", "cpp", ':let @+=expand("%:p")<CR>', DEFAULT_OPTIONS)

-- restore cursor position after joining lines
map("n", "J", "mzJ`z", DEFAULT_OPTIONS)

map("n", "<c-h>", ":TmuxNavigateLeft<cr>", { silent = true, noremap = true })
map("n", "<c-l>", ":TmuxNavigateRight<cr>", { silent = true, noremap = true })
map("n", "<c-j>", ":TmuxNavigateDown<cr>", { silent = true, noremap = true })
map("n", "<c-k>", ":TmuxNavigateUp<cr>", { silent = true, noremap = true })
map("n", "<M-y>", ":TmuxNavigateLeft<cr>", { silent = true, noremap = true })
map("n", "<M-e>", ":TmuxNavigateRight<cr>", { silent = true, noremap = true })
map("n", "<M-h>", ":TmuxNavigateDown<cr>", { silent = true, noremap = true })
map("n", "<M-a>", ":TmuxNavigateUp<cr>", { silent = true, noremap = true })

map("i", "<c-c>", "<ESC>", { silent = true, noremap = true })

map("n", "<TAB>", ":BufferLineCycleNext<CR>", DEFAULT_OPTIONS)
map("n", "<S-TAB>", ":BufferLineCyclePrev<CR>", DEFAULT_OPTIONS)

map("n", "<leader>;", function()
  Snacks.dashboard()
end)

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
