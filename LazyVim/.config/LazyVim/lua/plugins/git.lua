local _lmEnabled = false
local toggleLineMap = function()
  if _lmEnabled then
    _lmEnabled = false
    vim.cmd("set diffopt-=linematch:60")
  else
    _lmEnabled = true
    vim.cmd("set diffopt+=linematch:60")
  end
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
      { "<leader>gfv", "<cmd>:Gdiffsplit :1 | Gvdiffsplit!<CR>", desc = "3-way merge" },
      { "y<C-G>", "<cmd>call setreg(v:register, fugitive#Object(@%))<cr>", desc = "Copy git object" },
      { "<leader>gtd", "<cmd>Gitsigns toggle_deleted<cr>", desc = "Toggle deleted" },
      { "<leader>gtb", "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "Toggle line blame" },
    },
    config = function()
      vim.cmd([[
        :command! -nargs=1 Browse silent execute '!open' shellescape(<q-args>,1)
        :set diffopt+=vertical
        :set diffopt+=internal,algorithm:patience
        :set diffopt+=indent-heuristic
        :set diffopt+=algorithm:histogram
      ]])
    end,
  },
}
