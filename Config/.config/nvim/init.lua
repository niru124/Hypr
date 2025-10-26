-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.

vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.cpp",
  callback = function()
    local template_path =
      vim.fn.expand "~/.config/nvim/templates/cpp.template"
    vim.cmd("0r " .. template_path) -- Read the template into the buffer
  end,
})

vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.sh",
  callback = function()
    local template_path =
      vim.fn.expand "~/.config/nvim/templates/bash.template"
    vim.cmd("0r " .. template_path)
  end,
})

vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.ino",
  callback = function()
    local template_path =
      vim.fn.expand "~/.config/nvim/templates/ino.template"
    vim.cmd("0r " .. template_path)
  end,
})

local lazypath = vim.env.LAZY
  or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if
  not (
    vim.env.LAZY
    or (vim.uv or vim.loop).fs_stat(lazypath)
  )
then
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)
-- vim.opt.clipboard = "unnamedplus"

-- vim.opt.clipboard = "unnamedplus"
-- vim.g.clipboard = {
--   name = "wl-clipboard",
--   copy = {
--     ["+"] = "wl-copy",
--     ["*"] = "wl-copy --primary",
--   },
--   paste = {
--     ["+"] = "wl-paste",
--     ["*"] = "wl-paste --primary",
--   },
--   cache_enabled = 1,
-- }

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end
require "lazy_setup"
require "polish"
return {
  "OXY2DEV/markview.nvim",
  ft = function()
    local plugin =
      require("lazy.core.config").spec.plugins["markview.nvim"]
    local opts =
      require("lazy.core.plugin").values(
        plugin,
        "opts",
        false
      )
    return opts.filetypes
      or { "markdown", "quarto", "rmd" }
  end,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed =
          require("astrocore").list_insert_unique(
            opts.ensure_installed,
            {
              "html",
              "markdown",
              "markdown_inline",
            }
          )
      end
    end,
  },
  {
    "mikesmithgh/kitty-scrollback.nvim",
    enabled = true,
    lazy = true,
    cmd = {
      "KittyScrollbackGenerateKittens",
      "KittyScrollbackCheckHealth",
      "KittyScrollbackGenerateCommandLineEditing",
    },
    event = { "User KittyScrollbackLaunch" },
    -- version = '*', -- latest stable version, may have breaking changes if major version changed
    -- version = '^6.0.0', -- pin major version, include fixes and features that do not have breaking changes
    config = function()
      require("kitty-scrollback").setup()
    end,
  },
  opts = {
    hybrid_modes = { "n" },
    headings = { shift_width = 0 },
  },
  require("luasnip.loaders.from_lua").load {
    paths = "~/.config/nvim/lua/snippets",
  },

  "mluders/comfy-line-numbers.nvim",
}
