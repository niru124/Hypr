-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = {
        size = 136 * 32,
        lines = 10000,
      }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics_mode = 3, -- diagnostic mode on start (0 = off, 1 = no signs/virtual text, 2 = no virtual text, 3 = on)
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = true, -- sets vim.opt.wrap
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized.
    -- Each entry is either a string command, a function, or false to disable.
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- navigate buffer tabs
        ["<S-h>"] = {
          function() require("astrocore.buffer").nav(-vim.v.count1) end,
          desc = "Previous buffer",
        },
        ["<S-l>"] = {
          function() require("astrocore.buffer").nav(vim.v.count1) end,
          desc = "Next buffer",
        },

        -- mappings seen under group name "Buffer"
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        -- Telescope shortcuts
        ["<Leader><Leader>"] = { "<Cmd>Telescope find_files<CR>", desc = "Telescope Find Files" },
        ["<Leader><Leader>b"] = { "<Cmd>Telescope buffers<CR>", desc = "Telescope Buffers" },

        -- quality-of-life motions
        ["<S-e>"] = { "$", desc = "End of line" },
        ["<S-b>"] = { "0", desc = "Start of line" },

        -- floating terminal (setup/opts in plugins/toggleterm.lua)
        ["<C-/>"] = { "<Cmd>ToggleTerm direction=float<CR>", desc = "Toggle Floating Terminal" },
        ["<Leader>th"] = { "<Cmd>ToggleTerm direction=horizontal<CR>", desc = "ToggleTerm horizontal" },
        ["<Leader>tv"] = { "<Cmd>ToggleTerm direction=vertical<CR>", desc = "ToggleTerm vertical" },

        -- Open current file in new tab
        ["<Leader>te"] = { "<Cmd>tabedit %<CR>", desc = "Open current file in new tab" },

        -- Go to function implementation (v5 default moved to `gri`; keep `gi`).
        -- NOTE: `cond` is NOT allowed in astrocore mappings (only astrolsp
        -- mappings support it); it aborts the entire astrocore setup.
        ["gi"] = {
          function() vim.lsp.buf.implementation() end,
          desc = "Go to implementation",
        },
        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        -- ["<Leader>b"] = { desc = "Buffers" },

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,
      },
      t = {
        -- Go to Normal Mode in floating terminal
        ["<C-n>"] = { [[<C-\><C-n>]], desc = "Go to Normal Mode in Terminal" },
      },
    },
  },
}
