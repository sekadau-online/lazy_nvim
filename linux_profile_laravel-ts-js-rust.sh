#!/usr/bin/env bash
set -e

echo "===================================================="
echo " ⚙️  Neovim Full-Dev Setup (Laravel, Rust, JS, Tailwind)"
echo "===================================================="
sleep 1

NVIM_DIR="$HOME/.config/nvim"
BACKUP_DIR="$HOME/.config/nvim_backup_$(date +%Y-%m-%d_%H-%M-%S)"

echo "[1/6] Membuat backup konfigurasi lama..."
if [ -d "$NVIM_DIR" ]; then
  mv "$NVIM_DIR" "$BACKUP_DIR"
  echo "    Backup tersimpan di: $BACKUP_DIR"
fi

echo "[2/6] Membuat struktur folder..."
mkdir -p "$NVIM_DIR/lua/core" "$NVIM_DIR/lua/plugins"

echo "[3/6] Menulis init.lua..."
cat > "$NVIM_DIR/init.lua" <<'EOF'
vim.loader.enable()
require("core.options")
require("core.keymaps")
require("core.lazy")
EOF

echo "[4/6] Menulis core config..."
cat > "$NVIM_DIR/lua/core/options.lua" <<'EOF'
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8
EOF

cat > "$NVIM_DIR/lua/core/keymaps.lua" <<'EOF'
vim.g.mapleader = "\\"
local keymap = vim.keymap.set
keymap("n", "<leader>e", ":NvimTreeToggle<CR>")
keymap("n", "<leader>ff", ":Telescope find_files<CR>")
keymap("n", "<leader>fg", ":Telescope live_grep<CR>")
keymap("n", "<leader>tt", ":lua require('plugins.tinker').open_tinker()<CR>")
keymap("n", "<leader>d", ":TroubleToggle<CR>")
EOF

cat > "$NVIM_DIR/lua/core/lazy.lua" <<'EOF'
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({"git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath})
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup("plugins")
EOF

echo "[5/6] Menulis plugin config..."
cat > "$NVIM_DIR/lua/plugins/init.lua" <<'EOF'
return {
  "folke/tokyonight.nvim",
  "nvim-tree/nvim-web-devicons",
  "nvim-tree/nvim-tree.lua",
  "nvim-lualine/lualine.nvim",
  "akinsho/bufferline.nvim",
  "lukas-reineke/indent-blankline.nvim",
  "NvChad/nvim-colorizer.lua",
  "goolord/alpha-nvim",
  "nvim-telescope/telescope.nvim",
  "nvim-lua/plenary.nvim",
  "folke/which-key.nvim",
  "folke/trouble.nvim",
  "nvim-treesitter/nvim-treesitter",
  "windwp/nvim-autopairs",
  "numToStr/Comment.nvim",
  "kylechui/nvim-surround",
  "akinsho/toggleterm.nvim",
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",
  "neovim/nvim-lspconfig",
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "saadparwaiz1/cmp_luasnip",
  "L3MON4D3/LuaSnip",
  "rafamadriz/friendly-snippets",
  "jose-elias-alvarez/null-ls.nvim",
  "folke/todo-comments.nvim",
  "lewis6991/gitsigns.nvim",
  "nvimdev/dashboard-nvim",
}
EOF

cat > "$NVIM_DIR/lua/plugins/tinker.lua" <<'EOF'
local M = {}
function M.open_tinker()
  local Terminal = require("toggleterm.terminal").Terminal
  local artisan = vim.fn.getcwd() .. "/artisan"
  if vim.fn.filereadable(artisan) == 1 then
    Terminal:new({cmd="php artisan tinker", direction="float"}):toggle()
  else
    Terminal:new({direction="float"}):toggle()
  end
end
return M
EOF

cat > "$NVIM_DIR/lua/plugins/lsp.lua" <<'EOF'
require("mason").setup()
require("mason-lspconfig").setup {
  ensure_installed = {
    "intelephense", "rust_analyzer", "ts_ls",
    "html", "tailwindcss", "jsonls", "marksman"
  },
}
local lspconfig = require("lspconfig")
for _, lsp in ipairs({"intelephense","rust_analyzer","ts_ls","html","tailwindcss","jsonls","marksman"}) do
  lspconfig[lsp].setup {capabilities = require("cmp_nvim_lsp").default_capabilities()}
end
EOF

cat > "$NVIM_DIR/lua/plugins/cmp.lua" <<'EOF'
local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()
cmp.setup({
  snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fb)
      if cmp.visible() then cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
      else fb() end
    end, {"i","s"}),
  }),
  sources = {{name="nvim_lsp"}, {name="luasnip"}, {name="buffer"}, {name="path"}},
})
EOF

cat > "$NVIM_DIR/lua/plugins/ui.lua" <<'EOF'
vim.cmd[[colorscheme tokyonight]]
require("nvim-tree").setup()
require("lualine").setup({options={theme="tokyonight"}})
require("bufferline").setup{}
require("indent_blankline").setup{}
require("colorizer").setup()
require("which-key").setup()
require("trouble").setup()
require("nvim-treesitter.configs").setup{highlight={enable=true}}
require("toggleterm").setup()
require("Comment").setup()
require("nvim-surround").setup()
require("gitsigns").setup()
require("alpha").setup(require("alpha.themes.dashboard").config)
EOF

echo "[6/6] Menulis README..."
cat > "$NVIM_DIR/README.md" <<'EOF'
# Neovim Full-Dev Setup
## Shortcut
\e  → Toggle file explorer  
\ff → Cari file  
\fg → Cari teks  
\tt → Laravel Tinker / Terminal  
\d  → Trouble (error list)
## Update plugin
:Lazy sync
EOF

echo "===================================================="
echo "✅ Instalasi selesai!"
echo "Buka Neovim dan tunggu Lazy.nvim menginstal plugin:"
echo "    nvim"
echo "===================================================="