return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.setup = {
        tailwindcss = function(_, opts)
          local tw = LazyVim.lsp.get_raw_config("tailwindcss")
          opts.filetypes = opts.filetypes or {}

          -- Add default filetypes
          vim.list_extend(opts.filetypes, tw.default_config.filetypes)

          -- Remove excluded filetypes
          --- @param ft string
          opts.filetypes = vim.tbl_filter(function(ft)
            return not vim.tbl_contains(opts.filetypes_exclude or {}, ft)
          end, opts.filetypes)

          -- Additional settings for Phoenix projects
          opts.settings = {
            tailwindCSS = {
              includeLanguages = {
                elixir = "html-eex",
                eelixir = "html-eex",
                heex = "html-eex",
              },

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
          }

          -- Add additional filetypes
          vim.list_extend(opts.filetypes, opts.filetypes_include or {})
        end,
      }

      local pnp = vim.fn.findfile(".pnp.cjs", ".;")
      local is_pnp = pnp ~= ""
      local vtsls = opts.servers.vtsls
      if is_pnp then
        local root = vim.fn.fnamemodify(pnp, ":p:h")
        vtsls = vim.tbl_deep_extend("force", opts.servers.vtsls, {
          init_options = { hostInfo = "neovim" },
          settings = {
            typescript = {
              tsdk = root .. "/.yarn/sdks/typescript/lib",
            },
          },
        })
      end

      local eslint = opts.servers.eslint
      eslint = vim.tbl_deep_extend("force", eslint, {
        flags = {
          allow_incremental_sync = false,
          debounce_text_changes = 1000,
        },
      })

      opts.servers = vim.tbl_deep_extend("force", opts.servers, {
        eslint = eslint,
        vtsls = vtsls,
        nixd = require("lspconfig").nixd.setup({
          cmd = { "nixd" },
          settings = {
            nixd = {
              nixpks = {
                expr = "import <nixpkgs> {}",
              },
              formatting = {
                command = { "alejandra" },
              },
              options = {
                home_manager = {
                  expr = '(builtins.getFlake "/Users/david/dotfiles/nix-darwin").homeConfigurations.david.options',
                },
              },
            },
          },
        }),
      })
    end,
  },
}
