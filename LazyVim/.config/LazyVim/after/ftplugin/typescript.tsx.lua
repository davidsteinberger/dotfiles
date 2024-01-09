local map = vim.api.nvim_set_keymap
DEFAULT_OPTIONS = { noremap = true, silent = true }
map("n", "<Leader>cy", ":compiler tsc | setlocal makeprg=yarn\\ tsc\\ --noEmit<CR>", DEFAULT_OPTIONS)
map("n", "<Leader>cn", ":compiler tsc | setlocal makeprg=npm\\ run\\ tsc\\ --noEmit<CR>", DEFAULT_OPTIONS)
map("n", "<Leader>cc", ":Make<CR>", DEFAULT_OPTIONS)
