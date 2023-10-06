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
      { "y<C-G>", "<cmd>call setreg(v:register, fugitive#Object(@%))<cr>", desc = "Copy git object" },
      { "<leader>gtd", "<cmd>Gitsigns toggle_deleted<cr>", desc = "Toggle deleted" },
      { "<leader>gtb", "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "Toggle line blame" },
    },
    config = function()
      vim.cmd([[
        :command! -nargs=1 Browse silent execute '!open' shellescape(<q-args>,1)
      ]])
    end,
  },
}
