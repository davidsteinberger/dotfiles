local map = vim.api.nvim_set_keymap
DEFAULT_OPTIONS = { noremap = true, silent = true }
map("n", "<Leader>cc", ":compiler go | Make<CR>", DEFAULT_OPTIONS)
-- map(
--   "n",
--   "<Leader>cg",
--   ":execute '!oapi-codegen -config api/config.yaml api/openapi.yaml' <CR><CR> | :LspRestart <CR>",
--   DEFAULT_OPTIONS
-- )
map("n", "<Leader>cg", ":wall! | !go generate ./...<CR>", DEFAULT_OPTIONS)
map("n", "<Leader>ce", ":wall! | !go run ./...<CR>", DEFAULT_OPTIONS)
