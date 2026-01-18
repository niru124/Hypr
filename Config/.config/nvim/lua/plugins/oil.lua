vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.oil_position = vim.g.oil_position or "center"

local function setup_oil_float()
  local opts = {
    float = {
      border = "rounded",
      max_width = 80,
      max_height = 25,
    },
  }

  if vim.g.oil_position == "right" then
    opts.float.max_width = 30
    opts.float.max_height = 100
    opts.float.override = function(conf)
      conf.col = vim.o.columns - conf.width - 5
      return conf
    end
  elseif vim.g.oil_position == "left" then
    opts.float.max_width = 30
    opts.float.max_height = 100
    opts.float.override = function(conf)
      conf.col = 5
      return conf
    end
  end

  require("oil").setup(opts)
end

local function open_oil_float()
  setup_oil_float()
  require("oil").open_float(".")
end

vim.keymap.set("n", "<leader>e", function()
  if vim.bo.filetype == "oil" then
    vim.cmd "bwipeout"
  else
    open_oil_float()
  end
end, { desc = "Toggle oil explorer" })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "oil",
  callback = function()
    vim.keymap.set("n", "l", "<cmd>OilOpen<cr>", {
      buffer = true,
      desc = "Open file/directory",
    })
    vim.keymap.set(
      "n",
      "h",
      "<cmd>OilClose<cr>",
      {
        buffer = true,
        desc = "Go to parent directory",
      }
    )
  end,
})

vim.api.nvim_create_user_command("Oli", function(opts)
  local position = opts.args
  if position == "center" or position == "right" or position == "left" then
    vim.g.oil_position = position
    open_oil_float()
  else
    vim.notify("Unknown option: " .. position, vim.log.levels.ERROR)
  end
end, { nargs = 1, complete = function(arglead, _, _)
  local cmds = { "center", "right", "left" }
  return vim.tbl_filter(function(c) return vim.startswith(c, arglead) end, cmds)
end })

return {
  "stevearc/oil.nvim",
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    default_file_explorer = true,
    delete_to_trash = true,
    view_options = {
      show_hidden = true,
      natural_order = true,
    },
    float = {
      border = "rounded",
      max_width = 80,
      max_height = 25,
    },
  },
  dependencies = {
    { "nvim-mini/mini.icons", opts = {} },
  },
  lazy = false,
}
