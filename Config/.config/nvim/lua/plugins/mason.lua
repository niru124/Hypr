-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize Mason plugins

---@type LazySpec
return {
  -- use mason-lspconfig to configure LSP installations
  {
    "williamboman/mason-lspconfig.nvim",
    -- overrides `require("mason-lspconfig").setup(...)`
    opts = {
      ensure_installed = {
        "lua_ls",
        "arduino_language_server",
        "ast_grep",
        "bashls",
        "clangd",
        "jsonls",
        -- "stylua",
        -- cssls (keywords: css, scss, less)
        -- emmet-ls emmet_ls (keywords: emmet)
        -- eslint-lsp eslint (keywords: javascript, typescript)
        -- html-lsp html (keywords: html)
        -- jdtls (keywords: java)
        -- lemminx (keywords: xml)
        -- vtsls (keywords: javascript, typescript)
      },
    },
  },
  -- use mason-null-ls to configure Formatters/Linter installation for null-ls sources
  {
    "jay-babu/mason-null-ls.nvim",
    -- overrides `require("mason-null-ls").setup(...)`
    opts = {
      ensure_installed = {
        -- "stylua",
        "ast_grep",
        "beautysh",
        "clang-format",
        -- add more arguments for adding more null-ls sources
      },
    },
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    -- overrides `require("mason-nvim-dap").setup(...)`
    opts = {
      ensure_installed = {
        "codelldb",
        -- add more arguments for adding more debuggers
      },
    },
  },
}
