return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tailwindcss = {
          -- exclude a filetype from the default_config
          filetypes_exclude = { "markdown" },
          -- add additional filetypes to the default_config
          filetypes_include = {},
          -- to fully override the default_config, change the below
          -- filetypes = {}
        },
      },
      setup = {
        tailwindcss = function(_, opts)
          opts.filetypes = opts.filetypes or {}

          -- Add default filetypes
          vim.list_extend(opts.filetypes, vim.lsp.config.tailwindcss.filetypes)

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
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local eslint = opts.servers.eslint
      eslint = vim.tbl_deep_extend("force", eslint, {
        flags = {
          allow_incremental_sync = false,
          debounce_text_changes = 1000,
        },
      })
      opts.servers = vim.tbl_deep_extend("force", opts.servers, {
        eslint = eslint,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
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

      opts.servers = vim.tbl_deep_extend("force", opts.servers, {
        vtsls = vtsls,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = vim.tbl_deep_extend("force", opts.servers, {
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
