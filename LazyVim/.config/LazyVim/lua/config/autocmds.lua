-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local ft_group = vim.api.nvim_create_augroup("ft", { clear = true })

vim.api.nvim_create_autocmd({ "FileType" }, {
  group = ft_group,
  pattern = { "markdown" },
  callback = function()
    vim.wo.conceallevel = 1
  end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  group = ft_group,
  pattern = { "*.html", "*.tsx", "*.jsx", "typescriptreact", "javascriptreact" },
  callback = function()
    vim.wo.conceallevel = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "remove formatoptions",
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
})

vim.api.nvim_create_autocmd("VimLeave", {
  pattern = "*",
  command = "silent !zellij action switch-mode normal",
})
