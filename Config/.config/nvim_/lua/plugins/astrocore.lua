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
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- navigate buffer tabs
        -- Change leader + Shift+h to go to the previous buffer
        vim.api.nvim_set_keymap(
          "n",
          "<S-h>",
          '<Cmd>lua require("astrocore.buffer").nav(-1)<CR>',
          {
            noremap = true,
            silent = true,
            desc = "Previous buffer",
          }
        ),

        -- Change leader + Shift+l to go to the next buffer
        vim.api.nvim_set_keymap(
          "n",
          "<S-l>",
          '<Cmd>lua require("astrocore.buffer").nav(1)<CR>',
          {
            noremap = true,
            silent = true,
            desc = "Next buffer",
          }
        ),

        -- mappings seen under group name "Buffer"
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr)
                require("astrocore.buffer").close(
                  bufnr
                )
              end
            )
          end,
          desc = "Close buffer from tabline",
        },
        vim.api.nvim_set_keymap(
          "n",
          "<Leader><Leader>",
          "<Cmd>Telescope find_files<CR>",
          {
            noremap = true,
            silent = true,
            desc = "Telescope Find Files",
          }
        ),
        vim.api.nvim_set_keymap(
          "n",
          "<Leader><Leader>b",
          "<Cmd>Telescope buffers<CR>",
          {
            noremap = true,
            silent = true,
            desc = "Telescope Buffers",
          }
        ),

        -- Custom function to toggle floating terminal
        -- Set up toggleterm with floating window option
        require("toggleterm").setup {
          size = 20, -- You can customize the size of the floating terminal if needed
          direction = "float", -- Set terminal direction to 'float'
          float_opts = {
            border = "double", -- Set border style (e.g., 'rounded', 'single', 'double', etc.)
          },
          open_mapping = [[<c-\>]], -- Optional: Set the default toggle mapping (you can remove this line)
        },

        vim.api.nvim_set_keymap('n', '<S-e>', '$', { noremap = true, silent = true }),
        vim.api.nvim_set_keymap('n', '<S-b>', '0', { noremap = true, silent = true }),

        vim.api.nvim_set_keymap(
          "t",
          "<C-n>",
          [[<C-\><C-n>]],
          {
            noremap = true,
            silent = true,
            desc = "Go to Normal Mode in Terminal",
          }
        ),
        -- Map Ctrl+/ to toggle the terminal as a floating window
        vim.api.nvim_set_keymap(
          "n",
          "<C-/>",
          "<Cmd>ToggleTerm direction=float<CR>",
          {
            noremap = true,
            silent = true,
            desc = "Toggle Floating Terminal",
          }
        ),
        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        -- ["<Leader>b"] = { desc = "Buffers" },

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,
        vim.api.nvim_set_keymap(
          "n",
          "<Leader>th",
          ":ToggleTerm direction=horizontal<CR>",
          { noremap = true, silent = true }
        ),
        vim.api.nvim_set_keymap(
          "n",
          "<Leader>tv",
          ":ToggleTerm direction=vertical<CR>",
          { noremap = true, silent = true }
        ),

        -- Go to function implementation
        vim.api.nvim_set_keymap(
          "n",
          "gi",
          "<Cmd>lua vim.lsp.buf.implementation()<CR>",
          {
            noremap = true,
            silent = true,
            desc = "Go to implementation",
          }
        ),
      },
    },
  },
}
