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

-- 外部変更の自動反映
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  pattern = "*",
  callback = function()
    vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.WARN)
  end,
})

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

-- 言語別設定を読み込み
local ruby = require("langs.ruby")
local php = require("langs.php")

-- プラグイン設定
local plugins = {
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
  
  -- DAP (Debug Adapter Protocol)
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap" },
  },
}

-- 言語別プラグインを追加
for _, plugin in ipairs(ruby.plugins) do
  table.insert(plugins, plugin)
end

for _, plugin in ipairs(php.plugins) do
  table.insert(plugins, plugin)
end

-- lazy.nvimにプラグインを登録
require("lazy").setup(plugins)

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

-- 言語別LSP設定を適用
ruby.setup_lsp(capabilities, on_attach)
php.setup_lsp(capabilities, on_attach)

-- 言語別インデント設定を適用
ruby.setup_indent()
php.setup_indent()

-- Railsプロジェクト用キーマップ
ruby.setup_keymaps()

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

-- DAP設定
local dap = require("dap")
local dapui = require("dapui")

-- DAP UIセットアップ
dapui.setup()
require("nvim-dap-virtual-text").setup()

-- 言語別DAP設定を適用
ruby.setup_dap()

-- DAP UIを自動で開閉
dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end

-- デバッグ用キーマップ
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Continue" })
vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Step over" })
vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step into" })
vim.keymap.set("n", "<leader>du", dap.step_out, { desc = "Step out" })
vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Open REPL" })
vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Run last" })
vim.keymap.set("n", "<leader>dt", dapui.toggle, { desc = "Toggle DAP UI" })
vim.keymap.set("n", "<leader>dx", dap.terminate, { desc = "Terminate" })
