---@type LazySpec
return {
  "jkeresman01/spring-initializr.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    require("spring-initializr").setup()
  end,
}