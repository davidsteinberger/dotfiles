local _lmEnabled = true
local toggleLineMap = function()
  if _lmEnabled then
    _lmEnabled = false
    vim.cmd("set diffopt-=linematch:60")
  else
    _lmEnabled = true
    vim.cmd("set diffopt+=linematch:60")
  end
end

local diffget = function(buf)
  local c = "diffget " .. buf
  vim.cmd("set diffopt&")
  vim.cmd(c)
  vim.cmd([[
    set diffopt+=linematch:60
    diffupdate
  ]])
end

return {
  {
    "tpope/vim-fugitive",
    dependencies = {
      "tpope/vim-rhubarb",
    },
    cmd = {
      "G",
      "Git",
      "Gdiffsplit",
      "Gread",
      "Gwrite",
      "Ggrep",
      "GMove",
      "GDelete",
      "GBrowse",
      "GRemove",
      "GRename",
      "Glgrep",
      "Gedit",
      "GcLog",
    },
    ft = { "fugitive" },
    keys = {
      { "<leader>gf", desc = "Fugitive" },
      { "<leader>gff", "<cmd>G<cr>", desc = "Fugitive" },
      { "<leader>gft", "<cmd>0GcLog<cr>", desc = "TimeMachine" },
      { "<leader>gfl", toggleLineMap, desc = "Toggle linematch" },
      { "y<C-G>", "<cmd>call setreg(v:register, fugitive#Object(@%))<cr>", desc = "Copy git object" },
      { "<leader>gtd", "<cmd>Gitsigns toggle_deleted<cr>", desc = "Toggle deleted" },
      { "<leader>gtb", "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "Toggle line blame" },
    },
    config = function()
      vim.cmd([[
        :command! -nargs=1 Browse silent execute '!open' shellescape(<q-args>,1)
        :set diffopt+=linematch:60
      ]])
      vim.keymap.set("n", "dg2", function()
        diffget("//2")
      end)
      vim.keymap.set("n", "dg3", function()
        diffget("//3")
      end)
    end,
  },
}
