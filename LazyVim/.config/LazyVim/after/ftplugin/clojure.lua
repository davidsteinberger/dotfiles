local map = vim.keymap.set
DEFAULT_OPTIONS = { noremap = true, silent = true }
map("n", "<Leader>m", "<Cmd>ConjureEvalRootForm<CR>", DEFAULT_OPTIONS)
map("n", "<Leader>cj", "<Cmd>Clj!<CR>", DEFAULT_OPTIONS)
map("n", "<Leader>cef", "<Cmd>ConjureEvalFile<CR>", DEFAULT_OPTIONS)
map("n", "<Leader>cee", "<Cmd>ConjureEvalCurrentForm<CR>", DEFAULT_OPTIONS)
map("n", "<Leader>cer", "<Cmd>ConjureEvalRootForm<CR>", DEFAULT_OPTIONS)
map("n", "<Leader>cc", "<Cmd>ConjureConnect<CR>", DEFAULT_OPTIONS)
