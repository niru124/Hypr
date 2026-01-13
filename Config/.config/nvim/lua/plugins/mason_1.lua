---@type LazySpec
return {
  -----------------------------------------------------------------------------
  -- Core Mason Plugin
  -----------------------------------------------------------------------------
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

  -----------------------------------------------------------------------------
  -- Core LSP client
  -----------------------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
  },

  -----------------------------------------------------------------------------
  -- nvim-cmp LSP capabilities
  -----------------------------------------------------------------------------
  {
    "hrsh7th/cmp-nvim-lsp",
    lazy = true,
  },

  -----------------------------------------------------------------------------
  -- Mason ↔ LSP bridge
  -----------------------------------------------------------------------------
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        "lua_ls",
      },
      automatic_installation = true,
      handlers = {
        -- Default handler
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

        -- Lua (Neovim) specific config
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
      },
    },
  },

  -----------------------------------------------------------------------------
  -- Mason ↔ none-ls (formatters / linters)
  -----------------------------------------------------------------------------
  {
    "jay-babu/mason-null-ls.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "nvimtools/none-ls.nvim",
    },
    opts = {
      ensure_installed = {
        -- "stylua",
      },
      automatic_installation = true,
    },
  },

  -----------------------------------------------------------------------------
  -- none-ls core
  -----------------------------------------------------------------------------
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")

      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.formatting.stylua,
      })

      return opts
    end,
  },

  -----------------------------------------------------------------------------
  -- Mason ↔ DAP bridge
  -----------------------------------------------------------------------------
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    opts = {
      ensure_installed = {
        -- "python",
        -- "codelldb",
      },
      automatic_installation = true,
      handlers = {
        function() end, -- use default behavior
      },
    },
  },

  -----------------------------------------------------------------------------
  -- nvim-dap core
  -----------------------------------------------------------------------------
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")

      -- Load VS Code style launch.json if present
      pcall(function()
        require("dap.ext.vscode").load_launchjs()
      end)

      -- Example keymaps (optional)
      -- vim.keymap.set("n", "<F5>", dap.continue)
      -- vim.keymap.set("n", "<F10>", dap.step_over)
      -- vim.keymap.set("n", "<F11>", dap.step_into)
      -- vim.keymap.set("n", "<F12>", dap.step_out)
      -- vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint)
    end,
  },
}

