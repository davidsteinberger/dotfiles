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

local namespace = vim.api.nvim_create_namespace("class_conceal")
local group = vim.api.nvim_create_augroup("class_conceal", { clear = true })

local conceal_html_class = function(bufnr)
  local language_tree = vim.treesitter.get_parser(bufnr, "html")
  local syntax_tree = language_tree:parse()
  local root = syntax_tree[1]:root()

  local query = vim.treesitter.query.parse(
    "html",
    [[
    ((attribute
        (attribute_name) @att_name (#any-of? @att_name "class" "className" "tw")
        (quoted_attribute_value (attribute_value) @class_value) (#set! @class_value conceal "…")))
    ]]
  ) -- using single character for conceal thanks to u/Rafat913

  for _, captures, metadata in query:iter_matches(root, bufnr, root:start(), root:end_()) do
    local start_row, start_col, end_row, end_col = captures[2]:range()
    vim.api.nvim_buf_set_extmark(bufnr, namespace, start_row, start_col, {
      end_line = end_row,
      end_col = end_col,
      conceal = metadata[2].conceal,
    })
  end
end

-- // errors out in 0.10.0
-- vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "TextChanged", "InsertLeave" }, {
--   group = group,
--   pattern = { "*.html", "*.tsx", "*.jsx" },
--   callback = function()
--     conceal_html_class(vim.api.nvim_get_current_buf())
--   end,
-- })
