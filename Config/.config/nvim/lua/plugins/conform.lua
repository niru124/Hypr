---@type LazySpec
return {
  "stevearc/conform.nvim",
  lazy = true,
  enabled = true,
  event = "VeryLazy",
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "black" },
        cpp = { "clang_format" },
        c = { "clang_format" },
        sql = { "sqlfmt" },
        java = { "google_java_format" },
      },
      formatters = {
        stylua = {
          prepend_args = { "--indent-type", "Spaces" },
        },
        clang_format = {
          prepend_args = { "-style={BasedOnStyle: Google, IndentWidth: 2}" },
        },
        black = {
          prepend_args = { "--line-length", "100" },
        },
      },
    })
    vim.api.nvim_create_user_command("Format", function(args)
      require("conform").format({ async = true, lsp_fallback = true })
    end, { range = true })
  end,
}