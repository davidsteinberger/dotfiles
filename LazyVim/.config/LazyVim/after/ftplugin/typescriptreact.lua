local map = vim.keymap.set
DEFAULT_OPTIONS = { noremap = true, silent = true }
map("n", "<Leader>cy", ":compiler! tsc | set makeprg=yarn\\ tsc\\ --noEmit<CR>", DEFAULT_OPTIONS)
map("n", "<Leader>cn", ":compiler! tsc | set makeprg=npm\\ run\\ tsc\\ --noEmit<CR>", DEFAULT_OPTIONS)
map("n", "<Leader>m", ":Make<CR>", DEFAULT_OPTIONS)
