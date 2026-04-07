return {
  {
    "enekosarasola/mairu",
    dir = vim.fn.expand("~/mairu/integrations/nvim/mairu.nvim"),
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("mairu").setup({
        server = {
          auto_start = true,
          bin_path = vim.fn.expand("~/mairu/mairu/bin/mairu-agent"),
        },
      })
      require("mairu").set_default_keymaps()
    end,
  },
}
