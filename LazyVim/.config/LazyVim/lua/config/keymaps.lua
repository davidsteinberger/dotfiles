-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

DEFAULT_OPTIONS = { noremap = true, silent = true }
local map = vim.keymap.set

-- delete to blackhole register
map("x", "<bs>", '"_d', DEFAULT_OPTIONS)

-- map({ "n", "x", "v" }, "<bs><bs>", '"_diw', DEFAULT_OPTIONS)

-- shortcuts
map("n", "<bs>w", '"_ciw', DEFAULT_OPTIONS)
map("n", "<bs>p", '"_cw', DEFAULT_OPTIONS)
map("n", "<bs>d", function()
  vim.diagnostic.jump({ count = 1 })
end, DEFAULT_OPTIONS)
map("n", "<bs>D", function()
  vim.diagnostic.jump({ count = -1 })
end, DEFAULT_OPTIONS)
map("n", "<bs>q", ":cnext<cr>", DEFAULT_OPTIONS)
map("n", "<bs>Q", ":cprev<cr>", DEFAULT_OPTIONS)
map("n", "<bs>b", function()
  Snacks.bufdelete()
end, DEFAULT_OPTIONS)

-- copy entire buffer
map("n", "<leader>Y", ":%y+<cr>", DEFAULT_OPTIONS)

-- select from beginnig to end of line
map("n", "<leader>v", "^vg_", DEFAULT_OPTIONS)

-- copy relative path
map("n", "cp", ':let @+=fnamemodify(expand("%"), ":~:.")<cr>', DEFAULT_OPTIONS)
map("n", "cpp", ':let @+=expand("%:p")<cr>', DEFAULT_OPTIONS)

-- restore cursor position after joining lines
map("n", "J", "mzJ`z", DEFAULT_OPTIONS)

map("n", "<PageUp>", "<c-w><Up>", DEFAULT_OPTIONS)
map("n", "<PageDown>", "<c-w><Down>", DEFAULT_OPTIONS)
map("n", "<Home>", "<c-w><Left>", DEFAULT_OPTIONS)
map("n", "<End>", "<c-w><Right>", DEFAULT_OPTIONS)
map("n", "<S-Right>", ":BufferLineCycleNext<cr>", DEFAULT_OPTIONS)
map("n", "<S-Left>", ":BufferLineCyclePrev<cr>", DEFAULT_OPTIONS)
map("n", "<S-Up>", "N", DEFAULT_OPTIONS)
map("n", "<S-Down>", "n", DEFAULT_OPTIONS)

-- Herdr pane navigation (Graphite hjkl = y/h/a/e)
-- Moves to an adjacent vim split; falls back to herdr pane focus at the edge.
local function navigate(vim_dir, herdr_dir)
  local cur = vim.api.nvim_get_current_win()
  -- wincmd silently shifts focus to a background split when the current
  -- window is a floating terminal (e.g. lazygit), so treat that as "no move"
  -- too. Floating non-terminal windows (Snacks explorer, mini.files, pickers)
  -- navigate fine with wincmd, and non-floating terminals (e.g. the <c-/>
  -- split terminal) navigate fine too, so only skip wincmd for the
  -- floating+terminal combination.
  local floating = vim.api.nvim_win_get_config(cur).relative ~= ""
  local floating_terminal = floating and vim.bo.buftype == "terminal"
  if not floating_terminal then
    vim.cmd("wincmd " .. vim_dir)
  end
  if floating_terminal or vim.api.nvim_get_current_win() == cur then
    vim.fn.jobstart({ "herdr", "pane", "focus", "--direction", herdr_dir })
  end
end

map({ "n", "v", "t" }, "<M-Y>", function()
  navigate("h", "left")
end, DEFAULT_OPTIONS)
map({ "n", "v", "t" }, "<M-H>", function()
  navigate("j", "down")
end, DEFAULT_OPTIONS)
map({ "n", "v", "t" }, "<M-A>", function()
  navigate("k", "up")
end, DEFAULT_OPTIONS)
map({ "n", "v", "t" }, "<M-E>", function()
  navigate("l", "right")
end, DEFAULT_OPTIONS)

map("i", "<c-c>", "<esc>", DEFAULT_OPTIONS)

map("n", "<leader>;", function()
  Snacks.dashboard()
end)

vim.api.nvim_create_user_command("DarkMode", function(opts)
  DarkMode(opts.args == "true")
end, { nargs = "?" })

vim.api.nvim_create_user_command("LightMode", function()
  LightMode()
end, {})
