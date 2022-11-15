local map = vim.api.nvim_set_keymap
DEFAULT_OPTIONS = { noremap = true, silent = true }
map("n", "<F5>", ":wall!:compiler tsc | setlocal makeprg=yarn\\ tsc\\ --noEmit | make | copen<CR><CR>", DEFAULT_OPTIONS)
