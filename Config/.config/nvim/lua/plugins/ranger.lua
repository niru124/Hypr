---@type LazySpec
return {
  "kelly-lin/ranger.nvim",
  config = function()
    local ranger_nvim = require("ranger-nvim")
    ranger_nvim.setup({
      enable_cmds = false,
      replace_netrw = false,
      keybinds = {
        ["ov"] = ranger_nvim.OPEN_MODE.vsplit,
        ["oh"] = ranger_nvim.OPEN_MODE.split,
        ["ot"] = ranger_nvim.OPEN_MODE.tabedit,
        ["or"] = ranger_nvim.OPEN_MODE.rifle,
      },
      ui = {
        border = "none",
        height = 0.7,
        width = 0.75,
        x = 0.5,
        y = 0.5,
      }
    })
    vim.api.nvim_set_keymap("n", "<leader>e", "", {
      noremap = true,
      callback = function()
        require("ranger-nvim").open(true)
      end,
    })
  end,
}
