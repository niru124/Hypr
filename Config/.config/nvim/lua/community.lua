-- if true then return {} end -WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.cpp" },
  { import = "astrocommunity.pack.typescript" },
  {
    import = "astrocommunity.colorscheme.catppuccin",
  },
  -- { import = "astrocommunity.media.image-nvim" },
  -- { import = "astrocommunity.note-taking.neorg" },
  -- has problem will blurring(neo-tree)
  -- {
  -- import = "astrocommunity.scrolling.mini-animate",
  -- },
  {
    import = "astrocommunity.media.codesnap-nvim",
  },
  { import = "astrocommunity.motion.leap-nvim" },
  -- { import = "astrocommunity.pack.java" },
  {
    import = "astrocommunity.motion.nvim-surround",
  },
  {
    import = "astrocommunity.markdown-and-latex.render-markdown-nvim",
  },
  -- {
  --   import = "astrocommunity.pack.sql",
  -- },
}
