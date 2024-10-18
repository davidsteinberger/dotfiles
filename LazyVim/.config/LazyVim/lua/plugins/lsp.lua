return {
  {
    "neovim/nvim-lspconfig",
    keys = {
      { "<leader>uv", "<cmd>DiagnosticVirtual<cr>", desc = "Toggle Diagnostics Virtual" },
    },
    opts = function(_, opts)
      local pnp = vim.fn.findfile(".pnp.cjs", ".;")
      local is_pnp = pnp ~= ""
      local vtsls = opts.servers.vtsls
      if is_pnp then
        vtsls = vim.tbl_deep_extend("force", opts.servers.vtsls, {
          init_options = { hostInfo = "neovim" },
          settings = {
            typescript = {
              tsdk = "./.yarn/sdks/typescript/lib",
            },
          },
        })
      end

      opts.servers = vim.tbl_deep_extend("force", opts.servers, {
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
        vtsls = vtsls,
      })
    end,
  },
}
