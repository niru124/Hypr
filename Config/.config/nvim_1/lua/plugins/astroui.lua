-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    colorscheme = "catppuccin",
    highlights = {
      -- transparency
      init = {
        Comment = {
          fg = "#6c7086",
          bg = "NONE",
          italic = true,
        },
        Normal = { bg = "NONE" },
        NormalNC = { bg = "NONE" },
        NormalFloat = {
          bg = "NONE",
        },
        FloatBorder = {
          fg = "#8caaee",
          bold = true,
          bg = "NONE",
        },
        SignColumn = { bg = "NONE" },
        VertSplit = { bg = "NONE" },
        StatusLine = { bg = "NONE" },
        -- LineNr = { bg = "NONE" },
        LineNr = { fg = "#7f7f7f", bg = "NONE" }, -- Muted foreground for non-current lines
        CursorLineNr = {
          fg = "#ffffff",
          bg = "NONE",
          bold = true,
        },
        -- CursorLineNr = { bg = "NONE" },
        EndOfBuffer = { bg = "NONE" },
        TabLine = { bg = "NONE" },
        TabLineSel = { bg = "NONE" },
        TabLineFill = { bg = "NONE" },
        NeoTreeDotfile = {
          fg = "#ffffff",
          bg = "NONE",
          bold = true,
        },
      },
    },
    icons = {
      LSPLoading1 = "⠋",
      LSPLoading2 = "⠙",
      LSPLoading3 = "⠹",
      LSPLoading4 = "⠸",
      LSPLoading5 = "⠼",
      LSPLoading6 = "⠴",
      LSPLoading7 = "⠦",
      LSPLoading8 = "⠧",
      LSPLoading9 = "⠇",
      LSPLoading10 = "⠏",
    },
  },
}
