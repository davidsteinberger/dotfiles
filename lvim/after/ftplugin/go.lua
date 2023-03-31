local map = vim.api.nvim_set_keymap
DEFAULT_OPTIONS = { noremap = true, silent = true }
map("n", "<F12>", ":wall! | compiler go | make -o /dev/null <CR><CR> | :LspRestart <CR>", DEFAULT_OPTIONS)
map("n", "<S-F12>",
  ":execute '!oapi-codegen -config api/config.yaml api/openapi.yaml' <CR><CR> | :LspRestart <CR>"
  ,
  DEFAULT_OPTIONS)
map("n", "<F5>", ":wall! | !go run ./...<CR>", DEFAULT_OPTIONS)
