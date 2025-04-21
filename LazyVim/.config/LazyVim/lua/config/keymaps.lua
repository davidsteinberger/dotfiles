-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

DEFAULT_OPTIONS = { noremap = true, silent = true }
local map = vim.keymap.set

-- delete to blackhole register
map("x", "<BS>", '"_d', DEFAULT_OPTIONS)

-- change word
map("n", "<BS><BS>", '"_diw', DEFAULT_OPTIONS)
map("n", "<BS>w", '"_ciw', DEFAULT_OPTIONS)
map("n", "<BS>p", '"_cw', DEFAULT_OPTIONS)
map("n", "<BS>'", "\"_ci'", DEFAULT_OPTIONS)
map("n", '<BS>"', '"_ci"', DEFAULT_OPTIONS)

-- copy entire buffer
map("n", "<leader>Y", ":%y+<CR>", DEFAULT_OPTIONS)

-- select from beginnig to end of line
map("n", "<leader>v", "v_og_", DEFAULT_OPTIONS)

-- copy relative path
map("n", "cp", ':let @+=fnamemodify(expand("%"), ":~:.")<CR>', DEFAULT_OPTIONS)
map("n", "cpp", ':let @+=expand("%:p")<CR>', DEFAULT_OPTIONS)

-- restore cursor position after joining lines
map("n", "J", "mzJ`z", DEFAULT_OPTIONS)

map("n", "<c-h>", ":TmuxNavigateLeft<cr>", DEFAULT_OPTIONS)
map("n", "<c-l>", ":TmuxNavigateRight<cr>", DEFAULT_OPTIONS)
map("n", "<c-j>", ":TmuxNavigateDown<cr>", DEFAULT_OPTIONS)
map("n", "<c-k>", ":TmuxNavigateUp<cr>", DEFAULT_OPTIONS)
map("n", "<M-y>", ":TmuxNavigateLeft<cr>", DEFAULT_OPTIONS)
map("n", "<M-e>", ":TmuxNavigateRight<cr>", DEFAULT_OPTIONS)
map("n", "<M-h>", ":TmuxNavigateDown<cr>", DEFAULT_OPTIONS)
map("n", "<M-a>", ":TmuxNavigateUp<cr>", DEFAULT_OPTIONS)

map("i", "<c-c>", "<ESC>", DEFAULT_OPTIONS)

map("n", "<TAB>", ":BufferLineCycleNext<CR>", DEFAULT_OPTIONS)
map("n", "<S-TAB>", ":BufferLineCyclePrev<CR>", DEFAULT_OPTIONS)

map("n", "<leader>;", function()
  Snacks.dashboard()
end)

vim.api.nvim_create_user_command("DarkMode", function(opts)
  DarkMode(opts.args == "true")
end, { nargs = "?" })

vim.api.nvim_create_user_command("LightMode", function()
  LightMode()
end, {})

-- re-implement gx
local function do_open(uri)
  local cmd, err = vim.ui.open(uri)
  local rv = cmd and cmd:wait(1000) or nil
  if cmd and rv and rv.code ~= 0 then
    err = ("vim.ui.open: command %s (%d): %s"):format(
      (rv.code == 124 and "timeout" or "failed"),
      rv.code,
      vim.inspect(cmd.cmd)
    )
  end
  return err
end

local gx_desc = "Opens filepath or URI under cursor with the system handler (file explorer, web browser, …)"
vim.keymap.set({ "n" }, "<leader>gx", function()
  for _, url in ipairs(require("vim.ui")._get_urls()) do
    local err = do_open(url)
    if err then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end
end, { desc = gx_desc })
vim.keymap.set({ "x" }, "<leader>gx", function()
  local lines = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"), { type = vim.fn.mode() })
  -- Trim whitespace on each line and concatenate.
  local err = do_open(table.concat(vim.iter(lines):map(vim.trim):totable()))
  if err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = gx_desc })
