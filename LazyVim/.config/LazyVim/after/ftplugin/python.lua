-- local linters = require "lvim.lsp.null-ls.linters"
-- linters.setup({ { command = "flake8", filetypes = { "python" } } })
-- local formatters = require "lvim.lsp.null-ls.formatters"
-- formatters.setup { { command = "black" } }

local map = vim.api.nvim_set_keymap
DEFAULT_OPTIONS = { noremap = true, silent = true }
map("n", "<Leader>ce", ":execute '!python %'<CR>", DEFAULT_OPTIONS)
