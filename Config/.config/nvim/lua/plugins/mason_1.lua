---@type LazySpec
return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
        border = "single",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
  },
  {
    "hrsh7th/cmp-nvim-lsp",
    lazy = true,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        "lua_ls",
        "clangd",
        "jedi_language_server",
        "sqlls",
      },
      automatic_installation = true,
      handlers = {
        function(server_name)
          local capabilities = vim.lsp.protocol.make_client_capabilities()
          local ok, cmp = pcall(require, "cmp_nvim_lsp")
          if ok then
            capabilities = cmp.default_capabilities(capabilities)
          end

          require("lspconfig")[server_name].setup {
            capabilities = capabilities,
          }
        end,

        lua_ls = function()
          local capabilities = vim.lsp.protocol.make_client_capabilities()
          local ok, cmp = pcall(require, "cmp_nvim_lsp")
          if ok then
            capabilities = cmp.default_capabilities(capabilities)
          end

          require("lspconfig").lua_ls.setup {
            capabilities = capabilities,
            settings = {
              Lua = {
                runtime = { version = "LuaJIT" },
                diagnostics = { globals = { "vim" } },
                workspace = {
                  library = vim.api.nvim_get_runtime_file("", true),
                  checkThirdParty = false,
                },
                telemetry = { enable = false },
              },
            },
          }
        end,

        clangd = function()
          local capabilities = vim.lsp.protocol.make_client_capabilities()
          local ok, cmp = pcall(require, "cmp_nvim_lsp")
          if ok then
            capabilities = cmp.default_capabilities(capabilities)
          end

          require("lspconfig").clangd.setup {
            capabilities = capabilities,
            cmd = { "clangd", "--background-index" },
          }
        end,

        jedi_language_server = function()
          local capabilities = vim.lsp.protocol.make_client_capabilities()
          local ok, cmp = pcall(require, "cmp_nvim_lsp")
          if ok then
            capabilities = cmp.default_capabilities(capabilities)
          end

          require("lspconfig").jedi_language_server.setup {
            capabilities = capabilities,
          }
        end,

        sqlls = function()
          local capabilities = vim.lsp.protocol.make_client_capabilities()
          local ok, cmp = pcall(require, "cmp_nvim_lsp")
          if ok then
            capabilities = cmp.default_capabilities(capabilities)
          end

          require("lspconfig").sqlls.setup {
            capabilities = capabilities,
          }
        end,
      },
    },
  },
  {
    "jay-babu/mason-null-ls.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "nvimtools/none-ls.nvim",
    },
    opts = {
      ensure_installed = {
        "stylua",
        "clang-format",
        "black",
        "sqlfmt",
      },
      automatic_installation = true,
    },
  },
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")

      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.formatting.stylua,
        nls.builtins.formatting.clang_format,
        nls.builtins.formatting.black,
        nls.builtins.formatting.sqlfmt,
      })

      return opts
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    opts = {
      ensure_installed = {
        "codelldb",
        "debugpy",
      },
      automatic_installation = true,
      handlers = {
        function() end,
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")

      pcall(function()
        require("dap.ext.vscode").load_launchjs()
      end)
    end,
  },
}
