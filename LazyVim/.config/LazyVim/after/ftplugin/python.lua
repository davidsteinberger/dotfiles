local map = vim.keymap.set
DEFAULT_OPTIONS = { noremap = true, silent = true }
map("n", "<Leader>ce", ":Start python %<CR>", DEFAULT_OPTIONS)
