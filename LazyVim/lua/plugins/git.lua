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
      { "<leader>ghf", "<cmd>G<cr>", desc = "Fugitive" },
      { "<leader>ght", "<cmd>0GcLog<cr>", desc = "TimeMachine" },
      { "y<C-G>", "<cmd>call setreg(v:register, fugitive#Object(@%))<cr>", desc = "Copy git object" },
    },
  },
}
