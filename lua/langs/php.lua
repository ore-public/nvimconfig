local M = {}

-- PHPプラグイン
M.plugins = {
  {
    "jwalton512/vim-blade",
    ft = { "blade" },
  },
}

-- LSP設定
M.setup_lsp = function(capabilities, on_attach)
  vim.lsp.config.intelephense = {
    cmd = { "intelephense", "--stdio" },
    filetypes = { "php", "blade" },
    root_markers = { "composer.json", ".git" },
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      intelephense = {
        files = {
          maxSize = 1000000,
        },
      },
    },
  }
  
  vim.lsp.enable("intelephense")
end

-- インデント設定
M.setup_indent = function()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "php",
    callback = function()
      vim.opt_local.shiftwidth = 4
      vim.opt_local.tabstop = 4
      vim.opt_local.expandtab = true
    end,
  })
  
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "blade",
    callback = function()
      vim.opt_local.shiftwidth = 4
      vim.opt_local.tabstop = 4
      vim.opt_local.expandtab = true
    end,
  })
end

return M
