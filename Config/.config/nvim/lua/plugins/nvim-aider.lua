return {
  {
    "GeorgesAlkhouri/nvim-aider",
    cmd = "Aider",
    keys = {
      {
        "<leader>a/",
        "<cmd>Aider toggle<cr>",
        desc = "Toggle Aider",
      },
      {
        "<leader>as",
        "<cmd>Aider send<cr>",
        desc = "Send to Aider",
        mode = { "n", "v" },
      },
      {
        "<leader>ac",
        "<cmd>Aider command<cr>",
        desc = "Aider Commands",
      },
      {
        "<leader>ab",
        "<cmd>Aider buffer<cr>",
        desc = "Send Buffer",
      },
      {
        "<leader>a+",
        "<cmd>Aider add<cr>",
        desc = "Add File",
      },
      {
        "<leader>a-",
        "<cmd>Aider drop<cr>",
        desc = "Drop File",
      },
      {
        "<leader>ar",
        "<cmd>Aider add readonly<cr>",
        desc = "Add Read-Only",
      },
      {
        "<leader>a+",
        "<cmd>AiderTreeAddFile<cr>",
        desc = "Add File from Tree to Aider",
        ft = "NvimTree",
      },
      {
        "<leader>a-",
        "<cmd>AiderTreeDropFile<cr>",
        desc = "Drop File from Tree from Aider",
        ft = "NvimTree",
      },
    },
    dependencies = {
      "folke/snacks.nvim",
      "catppuccin/nvim",
      "nvim-tree/nvim-tree.lua",
      {
        "nvim-neo-tree/neo-tree.nvim",
        enabled = false,
        opts = function(_, opts)
          require("nvim_aider.neo_tree").setup(
            opts
          )
        end,
      },
    },
    config = true,
  },
}
