-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.

-- Portable config root (respects $XDG_CONFIG_HOME and $NVIM_APPNAME)
local config_dir = vim.fn.stdpath "config"

vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.cpp",
  callback = function()
    local template_path = config_dir
      .. "/templates/cpp.template"
    vim.cmd("0r " .. template_path) -- Read the template into the buffer
  end,
})

vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.sh",
  callback = function()
    local template_path = config_dir
      .. "/templates/bash.template"
    vim.cmd("0r " .. template_path)
  end,
})

vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.ino",
  callback = function()
    local template_path = config_dir
      .. "/templates/ino.template"
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

-- Portable clipboard: use the system clipboard when a provider exists.
-- Prefers Wayland (wl-copy), then X11 (xclip/xsel), macOS (pbcopy),
-- Windows (win32yank). Falls back to OSC 52 over SSH.
if vim.fn.executable "wl-copy" == 1 and vim.fn.executable "wl-paste" == 1 then
  vim.g.clipboard = {
    name = "wl-clipboard",
    copy = {
      ["+"] = "wl-copy",
      ["*"] = "wl-copy --primary",
    },
    paste = {
      ["+"] = "wl-paste",
      ["*"] = "wl-paste --primary",
    },
    cache_enabled = 1,
  }
  vim.opt.clipboard = "unnamedplus"
elseif vim.fn.executable "xclip" == 1 then
  vim.g.clipboard = {
    name = "xclip",
    copy = {
      ["+"] = "xclip -selection clipboard",
      ["*"] = "xclip -selection primary",
    },
    paste = {
      ["+"] = "xclip -selection clipboard -o",
      ["*"] = "xclip -selection primary -o",
    },
    cache_enabled = 1,
  }
  vim.opt.clipboard = "unnamedplus"
elseif vim.fn.executable "xsel" == 1 then
  vim.g.clipboard = {
    name = "xsel",
    copy = {
      ["+"] = "xsel --clipboard --input",
      ["*"] = "xsel --primary --input",
    },
    paste = {
      ["+"] = "xsel --clipboard --output",
      ["*"] = "xsel --primary --output",
    },
    cache_enabled = 1,
  }
  vim.opt.clipboard = "unnamedplus"
elseif vim.fn.has "mac" == 1 then
  vim.opt.clipboard = "unnamedplus" -- pbcopy/pbpaste via built-in provider
elseif vim.fn.has "wsl" == 1 and vim.fn.executable "win32yank.exe" == 1 then
  vim.g.clipboard = {
    name = "win32yank",
    copy = { ["+"] = "win32yank.exe -i", ["*"] = "win32yank.exe -i" },
    paste = { ["+"] = "win32yank.exe -o", ["*"] = "win32yank.exe -o" },
    cache_enabled = 1,
  }
  vim.opt.clipboard = "unnamedplus"
elseif vim.env.SSH_CONNECTION then
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy "+",
      ["*"] = require("vim.ui.clipboard.osc52").copy "*",
    },
    paste = {
      ["+"] = require("vim.ui.clipboard.osc52").paste "+",
      ["*"] = require("vim.ui.clipboard.osc52").paste "*",
    },
  }
  vim.opt.clipboard = "unnamedplus"
end

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end
require "lazy_setup"
require "polish"
