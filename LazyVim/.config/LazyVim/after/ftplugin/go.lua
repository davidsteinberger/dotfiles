local map = vim.keymap.set
DEFAULT_OPTIONS = { noremap = true, silent = true }
map("n", "<Leader>m", ":compiler! go | Make<CR>", DEFAULT_OPTIONS)
map("n", "<Leader>cg", ":wall! | !go generate ./...<CR>", DEFAULT_OPTIONS)
map("n", "<Leader>ce", ":wall! | !go run ./...<CR>", DEFAULT_OPTIONS)
