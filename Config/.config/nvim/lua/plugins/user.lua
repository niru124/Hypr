-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- You can also add or configure plugins by creating files in this `plugins/` folder
-- Here are some examples:

---@type LazySpec
return {

  -- == Examples of Adding Plugins ==
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    opts = function()
      local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
      local workspace_dir = vim.fn.stdpath "data" .. "/site/java/workspace-root/" .. project_name
      vim.fn.mkdir(workspace_dir, "p")

      return {
        cmd = {
          "java",
          "-Declipse.application=org.eclipse.jdt.ls.core.id1",
          "-Dosgi.bundles.defaultStartLevel=4",
          "-Declipse.product=org.eclipse.jdt.ls.core.product",
          "-Dlog.protocol=true",
          "-Dlog.level=ALL",
          "-javaagent:" .. vim.fn.expand "$MASON/share/jdtls/lombok.jar",
          "-Xms1g",
          "--add-modules=ALL-SYSTEM",
          "--add-opens", "java.base/java.util=ALL-UNNAMED",
          "--add-opens", "java.base/java.lang=ALL-UNNAMED",
          "-jar", vim.fn.expand "$MASON/share/jdtls/plugins/org.eclipse.equinox.launcher.jar",
          "-configuration", vim.fn.expand "$MASON/share/jdtls/config",
          "-data", workspace_dir,
        },
        root_dir = function() return vim.fs.root(0, { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }) end,
        settings = {
          java = {
            eclipse = { downloadSources = true },
            configuration = { updateBuildConfiguration = "interactive" },
            maven = { downloadSources = true },
          },
        },
        init_options = {
          bundles = {
            vim.fn.expand "$MASON/share/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin.jar",
            (table.unpack or unpack)(vim.split(vim.fn.glob "$MASON/share/java-test/extension/server/*.jar", "\n", {})),
          },
        },
      }
    end,
    config = function(_, opts)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = function()
          if opts.root_dir() then
            require("jdtls").start_or_attach(opts)
          end
        end,
      })
      vim.api.nvim_create_autocmd("LspAttach", {
        pattern = "*.java",
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "jdtls" then
            require("jdtls").setup_dap { hotcodereplace = "auto" }
            require("jdtls.dap").setup_dap_main_class_configs()
          end
        end,
      })
    end,
  },

  "andweeb/presence.nvim",
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      opts.window = {
        completion = {
          col_offset = -1,
          side_padding = 0,
        },
        documentation = {
          border = "rounded",
          winhighlight = "NormalFloat:Normal,FloatBorder:Normal",
        },
      }
      opts.formatting = {
        format = function(entry, vim_item)
          if vim.bo.filetype == "java" then
            vim_item.detail = nil
          end
          return vim_item
        end,
      }
      return opts
    end,
  },
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function() require("lsp_signature").setup() end,
  },

  -- == Examples of Overriding Plugins ==

  -- customize alpha options
  {
    "goolord/alpha-nvim",
    opts = function(_, opts)
      -- customize the dashboard header
      opts.section.header.val = {
        "         ,--.              ,----..                                 ____   ",
        "       ,--.'|    ,---,.   /   /   \\                 ,---,        ,'  , `. ",
        "   ,--,:  : |  ,'  .' |  /   .     :        ,---.,`--.' |     ,-+-,.' _ | ",
        ",`--.'`|  ' :,---.'   | .   /   ;.  \\      /__./||   :  :  ,-+-. ;   , || ",
        "|   :  :  | ||   |   .'.   ;   /  ` ; ,---.;  ; |:   |  ' ,--.'|'   |  ;| ",
        ":   |   \\ | ::   :  |-,;   |  ; \\ ; |/___/ \\  | ||   :  ||   |  ,', |  ': ",
        "|   : '  '; |:   |  ;/||   :  | ; | '\\   ;  \\ ' |'   '  ;|   | /  | |  || ",
        "'   ' ;.    ;|   :   .'.   |  ' ' ' : \\   \\  \\: ||   |  |'   | :  | :  |, ",
        "|   | | \\   ||   |  |-,'   ;  \\; /  |  ;   \\  ' .'   :  ;;   . |  ; |--'  ",
        "'   : |  ; .''   :  ;/| \\   \\  ',  /    \\   \\   '|   |  '|   : |  | ,     ",
        "|   | '`--'  |   |    \\  ;   :    /      \\   `  ;'   :  ||   : '  |/      ",
        "'   : |      |   :   .'   \\   \\ .'        :   \\ |;   |.' ;   | |`-'       ",
        ";   |.'      |   | ,'      `---`           '---\" '---'   |   ;/           ",
        "'---'        `----'                                      '---'            ",
      }
      return opts
    end,
  },

  -- You can disable default plugins as follows:
  { "max397574/better-escape.nvim", enabled = false },

  -- You can also easily customize additional setup of plugins that is outside of the plugin's setup call
  {
    "L3MON4D3/LuaSnip",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.luasnip"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom luasnip configuration such as filetype extend or custom snippets
      local luasnip = require "luasnip"
      luasnip.filetype_extend("javascript", { "javascriptreact" })
    end,
  },
{
  "mikesmithgh/kitty-scrollback.nvim",
  enabled = true,
  lazy = true,
  cmd = {
    "KittyScrollbackGenerateKittens",
    "KittyScrollbackCheckHealth",
    "KittyScrollbackGenerateCommandLineEditing",
  },
  event = { "User KittyScrollbackLaunch" },
  config = function()
    require("kitty-scrollback").setup()
  end,
},
  {
    "windwp/nvim-autopairs",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom autopairs configuration such as filetype extend or custom snippets
      local npairs = require "nvim-autopairs"
      local Rule = require "nvim-autopairs.rule"
      local cond = require "nvim-autopairs.conds"
      npairs.add_rules(
        {
          Rule("$", "$", { "tex", "latex" })
            -- don't add a pair if the next character is %
            :with_pair(cond.not_after_regex "%%")
            -- don't add a pair if  the previous character is xxx
            :with_pair(
              cond.not_before_regex("xxx", 3)
            )
            -- don't move right when repeat character
            :with_move(cond.none())
            -- don't delete if the next character is xx
            :with_del(cond.not_after_regex "xx")
            -- disable adding a newline when you press <cr>
            :with_cr(cond.none()),
        },
        -- disable for .vim files, but it work for another filetypes
        Rule("a", "a", "-vim")
      )
    end,
  },
}
