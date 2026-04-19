-- Customize Mason plugins

---@type LazySpec
return {
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "lua_ls",
        "clangd",
        "jedi_language_server",
        "jdtls",
        "arduino_language_server",
      },
    },
  },
  {
    "jay-babu/mason-null-ls.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "clang-format",
        "black",
        "beautysh",
        "sqlfmt",
        "google-java-format",
      },
    },
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = {
      ensure_installed = {
        "codelldb",
        "debugpy",
        "java-test",
        "java-debug-adapter",
      },
    },
  },
}
