return {
  {
    "neovim/nvim-lspconfig",
    keys = {
      { "<leader>uv", "<cmd>DiagnosticVirtual<cr>", desc = "Toggle Diagnostics Virtual" },
    },
    opts = {
      servers = {
        -- tsserver = {
        --   root_dir = function(...)
        --     return require("lspconfig.util").root_pattern(".git")(...)
        --   end,
        -- },
        tailwindcss = {
          settings = {
            tailwindCSS = {
              experimental = {
                classRegex = {
                  "tw`([^`]*)",
                  'tw="([^"]*)',
                  'tw={"([^"}]*)',
                  "tw\\.\\w+`([^`]*)",
                  "tw\\(.*?\\)`([^`]*)",
                },
              },
            },
          },
        },
      },
    },
  },
}
