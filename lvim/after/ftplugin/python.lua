local map = vim.api.nvim_set_keymap
DEFAULT_OPTIONS = { noremap = true, silent = true }
map("n", "<F12>", ":wall! | :execute '!python3 %'<CR>", DEFAULT_OPTIONS)
