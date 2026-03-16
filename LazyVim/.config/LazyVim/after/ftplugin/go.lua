local map = vim.keymap.set
DEFAULT_OPTIONS = { noremap = true, silent = true }
local util = require("util")

map("n", "<Leader>m", function()
  util.make_async("go build ./... 2>&1", {
    title = "go",
    efm = "%-G#\\ %.%#,%A%f:%l:%c:\\ %m,%A%f:%l:\\ %m,%C%*\\\\s%m,%-G%.%#",
  })
end, DEFAULT_OPTIONS)
map("n", "<Leader>cg", ":Start go generate ./...<CR>", DEFAULT_OPTIONS)
map("n", "<Leader>ce", ":Start go run ./...<CR>", DEFAULT_OPTIONS)
