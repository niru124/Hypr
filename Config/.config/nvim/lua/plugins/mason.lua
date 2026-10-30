-- Mason package management (AstroNvim v5 style).
-- All LSP servers, DAP adapters, linters and formatters are declared once
-- here by *Mason registry name* and auto-installed on startup
-- (mason-tool-installer runs on start by default). This is what makes the
-- config self-provisioning on a fresh machine: only the external toolchains
-- (node, python, java, clang, ...) must exist -- see install.sh.
-- NOTE: names here are Mason registry names, NOT lspconfig names
-- (e.g. `lua-language-server`, not `lua_ls`).

---@type LazySpec
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        -- LSP servers (lspconfig name -> Mason name)
        "lua-language-server", -- lua_ls
        "clangd", -- clangd
        "jedi-language-server", -- jedi_language_server
        "jdtls", -- jdtls (java)
        "arduino-language-server", -- arduino_language_server
        -- DAP adapters
        "codelldb", -- c/cpp/rust debugger
        "debugpy", -- python debugger
        "java-test", -- java test runner
        "java-debug-adapter", -- java debugger
        -- Formatters (used by conform.nvim, see conform.lua)
        "stylua", -- lua
        "black", -- python
        "clang-format", -- c/cpp
        "sqlfmt", -- sql
        "google-java-format", -- java
      },
    },
  },
  -- none-ls is disabled in favor of conform.nvim (see user.lua + conform.lua)
  { "jay-babu/mason-null-ls.nvim", enabled = false },
}
