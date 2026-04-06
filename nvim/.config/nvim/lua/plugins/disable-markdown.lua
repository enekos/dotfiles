return {
  -- Disable markdown LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        marksman = false,
      },
    },
  },

  -- Disable markdown linting in nvim-lint
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.markdown = nil
      opts.linters_by_ft["markdown.mdx"] = nil
    end,
  },

  -- Disable markdown validation/formatting in conform.nvim
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.markdown = nil
      opts.formatters_by_ft["markdown.mdx"] = nil
    end,
  },

  -- Disable none-ls markdown tools
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      if opts.sources then
        opts.sources = vim.tbl_filter(function(source)
          local name = source.name or ""
          return not name:match("markdownlint") and not name:match("marksman")
        end, opts.sources)
      end
    end,
  },

  -- Prevent mason from ensuring installation of markdown tools
  {
    "williamboman/mason.nvim",
    optional = true,
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        opts.ensure_installed = vim.tbl_filter(function(name)
          return not vim.tbl_contains({ "marksman", "markdownlint", "markdownlint-cli2" }, name)
        end, opts.ensure_installed)
      end
    end,
  },
}
