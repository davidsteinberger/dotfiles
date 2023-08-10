return {
  {
    "neovim/nvim-lspconfig",
    keys = {
      { "<leader>tv", "<cmd>DiagnosticVirtual<cr>", desc = "Toggle Diagnostics Virtual" },
    },
    opts = {
      diagnostics = {
        virtual_text = false,
        underline = true,
      },
      servers = {
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
