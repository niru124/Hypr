-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    features = {
      codelens = true,
      inlay_hints = false,
      semantic_tokens = true,
    },
    formatting = {
      format_on_save = {
        enabled = true,
      },
      timeout_ms = 1000,
    },
    -- NOTE (AstroNvim v5): per-filetype formatter selection lives in
    -- conform.nvim (see plugins/conform.lua), not here.
    config = {
      clangd = {
        capabilities = {
          offsetEncoding = "utf-8",
        },
        cmd = { "clangd", "--background-index", "--compile-commands-dir=." },
      },
      lua_ls = {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
              library = vim.api.nvim_get_runtime_file(
                "",
                true
              ),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
          },
        },
      },
      jedi_language_server = {},
      jdtls = {
        settings = {
          java = {
            eclipse = { downloadSources = true },
            configuration = { updateBuildConfiguration = "interactive" },
            maven = { downloadSources = true },
            implementationsCodeLens = { enabled = true },
            referencesCodeLens = { enabled = true },
            references = { includeDecompiledSources = true },
            inlayHints = { parameterNames = { enabled = "all" } },
          },
        },
      },
      -- sqlls = {},
    },
    mappings = {
      n = {
        gD = {
          function() vim.lsp.buf.declaration() end,
          desc = "Declaration of current symbol",
          cond = "textDocument/declaration",
        },
        ["<Leader>uY"] = {
          function()
            require("astrolsp.toggles").buffer_semantic_tokens()
          end,
          desc = "Toggle LSP semantic highlight (buffer)",
          cond = function(client)
            return client.server_capabilities.semanticTokensProvider ~= nil
          end,
        },
      },
    },
  },
}
