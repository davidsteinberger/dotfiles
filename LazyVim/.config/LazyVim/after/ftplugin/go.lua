local map = vim.keymap.set
DEFAULT_OPTIONS = { noremap = true, silent = true }
map("n", "<Leader>m", ":compiler! go | Make<CR>", DEFAULT_OPTIONS)
map("n", "<Leader>cg", ":Start go generate ./...<CR>", DEFAULT_OPTIONS)
map("n", "<Leader>ce", ":Start go run ./...<CR>", DEFAULT_OPTIONS)
