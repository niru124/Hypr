return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = {
      -- Optional: Make the border of the Neo-tree float transparent too
      win_config = {
        border = "rounded",
        winblend = 0, -- Needed for background transparency in floating mode
      },
    },
    -- Apply transparent background to key UI elements
    default_component_configs = {
      icon = {
        folder_closed = "",
        folder_open = "",
      },
    },
    filesystem = {
      follow_current_file = { enabled = true },
    },
  },
  config = function(_, opts)
    require("neo-tree").setup(opts)

    -- Highlight overrides for transparency
    local hl = vim.api.nvim_set_hl
    hl(0, "NeoTreeNormal", { bg = "NONE" })
    hl(0, "NeoTreeNormalNC", { bg = "NONE" })
    hl(0, "NeoTreeEndOfBuffer", { bg = "NONE" })
    hl(
      0,
      "NeoTreeWinSeparator",
      { bg = "NONE", fg = "#555555" }
    ) -- Optional
    hl(
      0,
      "NeoTreeVertSplit",
      { bg = "NONE", fg = "#444444" }
    ) -- Optional
  end,
}
