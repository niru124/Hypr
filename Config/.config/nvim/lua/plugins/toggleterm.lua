-- Floating terminal defaults (merged with AstroNvim's toggleterm spec).
-- The keymaps (<C-/>, <Leader>th/tv) live in astrocore.lua mappings.

---@type LazySpec
return {
  "akinsho/toggleterm.nvim",
  opts = {
    size = 20,
    direction = "float", -- default direction for :ToggleTerm
    float_opts = {
      border = "double",
    },
    open_mapping = [[<c-\>]],
  },
}
