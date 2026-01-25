local M = {}

-- Rubyプラグイン
M.plugins = {
  {
    "vim-ruby/vim-ruby",
    ft = { "ruby", "eruby" },
  },
  {
    "tpope/vim-rails",
    ft = { "ruby", "eruby" },
  },
  {
    "tpope/vim-bundler",
    ft = { "ruby", "eruby" },
  },
  {
    "tpope/vim-endwise",
    ft = { "ruby", "eruby" },
  },
  {
    "tpope/vim-haml",
    ft = { "haml", "sass", "scss" },
  },
  {
    "suketa/nvim-dap-ruby",
    dependencies = { "mfussenegger/nvim-dap" },
  },
}

-- LSP設定
M.setup_lsp = function(capabilities, on_attach)
  vim.lsp.config.solargraph = {
    cmd = { vim.fn.expand("~/.rbenv/shims/solargraph"), "stdio" },
    filetypes = { "ruby" },
    root_markers = { "Gemfile", ".git" },
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      solargraph = {
        diagnostics = true,
        formatting = true,
      },
    },
  }
  
  vim.lsp.enable("solargraph")
end

-- インデント設定
M.setup_indent = function()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "ruby",
    callback = function()
      vim.opt_local.shiftwidth = 2
      vim.opt_local.tabstop = 2
      vim.opt_local.expandtab = true
    end,
  })
  
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "haml",
    callback = function()
      vim.opt_local.shiftwidth = 2
      vim.opt_local.tabstop = 2
      vim.opt_local.expandtab = true
    end,
  })
  
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "sass", "scss" },
    callback = function()
      vim.opt_local.shiftwidth = 2
      vim.opt_local.tabstop = 2
      vim.opt_local.expandtab = true
    end,
  })
  
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "eruby",
    callback = function()
      vim.opt_local.shiftwidth = 2
      vim.opt_local.tabstop = 2
      vim.opt_local.expandtab = true
    end,
  })
end

-- キーマップ
M.setup_keymaps = function()
  vim.keymap.set("n", "<leader>ra", ":A<CR>", { desc = "Rails alternate file" })
  vim.keymap.set("n", "<leader>rr", ":R<CR>", { desc = "Rails related file" })
  vim.keymap.set("n", "<leader>rm", ":Emodel ", { desc = "Rails model" })
  vim.keymap.set("n", "<leader>rc", ":Econtroller ", { desc = "Rails controller" })
  vim.keymap.set("n", "<leader>rv", ":Eview ", { desc = "Rails view" })
end

-- DAP設定
M.setup_dap = function()
  local dap = require("dap")
  
  dap.adapters.ruby = function(callback, config)
    callback({
      type = "server",
      host = config.host or "127.0.0.1",
      port = config.port or 38698,
    })
  end
  
  dap.configurations.ruby = {
    {
      type = "ruby",
      name = "Attach to Foreman Rails (rdbg)",
      request = "attach",
      host = "127.0.0.1",
      port = 38698,
    },
  }
end

return M
