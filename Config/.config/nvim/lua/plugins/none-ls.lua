---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, opts)
    local null_ls = require("null-ls")

    opts.sources = require("astrocore").list_insert_unique(opts.sources, {
      null_ls.builtins.formatting.stylua.with({ extra_args = { "--indent-type", "Spaces" } }),
      null_ls.builtins.formatting.clang_format.with({
        extra_args = { "-style", "{BasedOnStyle: Google, IndentWidth: 2}" },
      }),
      null_ls.builtins.formatting.black.with({ extra_args = { "--line-length", "100" } }),
      null_ls.builtins.formatting.sqlfmt,
      null_ls.builtins.diagnostics.mypy,
    })
  end,
}
