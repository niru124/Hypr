-- if true then return {} end -WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.cpp" },
  { import = "astrocommunity.pack.python" },
  { import = "astrocommunity.pack.sql" },
  {
    import = "astrocommunity.colorscheme.catppuccin",
  },
  { import = "astrocommunity.motion.leap-nvim" },
  {
    import = "astrocommunity.motion.nvim-surround",
  },
  {
    import = "astrocommunity.markdown-and-latex.markview-nvim",
  },
}
