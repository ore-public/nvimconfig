-- 基本設定
vim.opt.number = true
-- vim.opt.relativenumber = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 300

-- リーダーキー
vim.g.mapleader = " "

-- lazy.nvimのセットアップ
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- プラグイン設定
require("lazy").setup({
  -- LSP関連
  {
    "neovim/nvim-lspconfig",
  },
  
  -- Haskell専用ツール（自動でHLSを管理）
  {
    "mrcjkb/haskell-tools.nvim",
    version = "^4",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
  
  -- 補完
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
  },
  
  -- ファジーファインダー
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      local actions = require("telescope.actions")
      
      require("telescope").setup({
        defaults = {
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
            },
          },
        },
        pickers = {
          git_branches = {
            mappings = {
              i = {
                ["<CR>"] = function(prompt_bufnr)
                  local selection = require("telescope.actions.state").get_selected_entry()
                  actions.close(prompt_bufnr)
                  local branch = selection.value
                  
                  -- リモートブランチの場合
                  if branch:match("^origin/") or branch:match("^remotes/origin/") then
                    -- origin/ または remotes/origin/ を削除
                    local local_branch = branch:gsub("^remotes/origin/", ""):gsub("^origin/", "")
                    -- ローカルブランチが既に存在するか確認
                    local result = vim.fn.system("git rev-parse --verify " .. local_branch .. " 2>/dev/null")
                    if vim.v.shell_error == 0 then
                      -- 既存のローカルブランチをチェックアウト
                      vim.cmd("Git checkout " .. local_branch)
                    else
                      -- 新規ローカルブランチを作成してリモートをトラッキング
                      vim.cmd("Git checkout -t origin/" .. local_branch)
                    end
                  else
                    -- ローカルブランチ
                    vim.cmd("Git checkout " .. branch)
                  end
                end,
              },
            },
          },
        },
      })
      
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
    end,
  },
  
  -- カラースキーム
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },
  
  -- ファイルツリー
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file tree" })
    end,
  },
  
  -- Rails開発用プラグイン
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
  
  -- HAML/SASS対応
  {
    "tpope/vim-haml",
    ft = { "haml", "sass", "scss" },
  },
  
  -- コメントアウト
  {
    "tpope/vim-commentary",
  },
  
  -- Auto pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },
  
  -- Git統合
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },
  {
    "tpope/vim-fugitive",
  },
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  
  -- ステータスライン
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "catppuccin",
        },
      })
    end,
  },
})

-- nvim-cmp補完設定
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "path" },
  }),
})

-- Haskell Tools設定
local ht = require("haskell-tools")

vim.g.haskell_tools = {
  hls = {
    on_attach = function(client, bufnr)
      local opts = { buffer = bufnr, noremap = true, silent = true }
      
      -- LSP基本キーバインド
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
      vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, opts)
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
      vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
      
      -- Haskell固有の機能
      vim.keymap.set("n", "<leader>hs", ht.hoogle.hoogle_signature, opts)
      vim.keymap.set("n", "<leader>ea", ht.lsp.buf_eval_all, opts)
      vim.keymap.set("n", "<leader>rr", ht.repl.toggle, opts)
      vim.keymap.set("n", "<leader>rf", function() ht.repl.toggle(vim.api.nvim_buf_get_name(0)) end, opts)
    end,
    default_settings = {
      ["haskell-language-server"] = {
        formattingProvider = "ormolu",
      },
    },
  },
}

-- 診断表示の設定
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
  },
})

-- 診断記号
local signs = { Error = "✘", Warn = "▲", Hint = "⚑", Info = "»" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- Ruby LSP設定
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local on_attach = function(client, bufnr)
  local opts = { buffer = bufnr, noremap = true, silent = true }
  
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, opts)
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
end

-- Solargraph (Ruby LSP) with rbenv support
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

-- ファイルタイプ別のインデント設定
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

-- Railsプロジェクト用キーマップ
vim.keymap.set("n", "<leader>ra", ":A<CR>", { desc = "Rails alternate file" })
vim.keymap.set("n", "<leader>rr", ":R<CR>", { desc = "Rails related file" })
vim.keymap.set("n", "<leader>rm", ":Emodel ", { desc = "Rails model" })
vim.keymap.set("n", "<leader>rc", ":Econtroller ", { desc = "Rails controller" })
vim.keymap.set("n", "<leader>rv", ":Eview ", { desc = "Rails view" })

-- Git操作用キーマップ
vim.keymap.set("n", "<leader>gs", ":Git<CR>", { desc = "Git status" })
vim.keymap.set("n", "<leader>gc", ":Git commit<CR>", { desc = "Git commit" })
vim.keymap.set("n", "<leader>gp", ":Git push<CR>", { desc = "Git push" })
vim.keymap.set("n", "<leader>gl", ":Git pull<CR>", { desc = "Git pull" })
vim.keymap.set("n", "<leader>gm", ":Git merge ", { desc = "Git merge" })
vim.keymap.set("n", "<leader>gb", ":Git blame<CR>", { desc = "Git blame" })
vim.keymap.set("n", "<leader>gd", ":DiffviewOpen<CR>", { desc = "Diff view" })
vim.keymap.set("n", "<leader>gh", ":DiffviewFileHistory %<CR>", { desc = "File history" })
vim.keymap.set("n", "<leader>go", ":Git checkout ", { desc = "Git checkout" })
vim.keymap.set("n", "<leader>gB", ":Telescope git_branches<CR>", { desc = "Git branches" })
