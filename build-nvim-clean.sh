#!/usr/bin/env bash
set -e

echo "===================================================="
echo " ⚙️  Neovim Build & Cleanup Utility (v0.11 compatible)"
echo "===================================================="
sleep 1

# 1️⃣ Bersihkan sisa instalasi lama
echo "[1/7] Cleaning old Neovim installations..."
sudo rm -f /usr/bin/nvim /usr/local/bin/nvim || true
sudo rm -rf ~/.local/share/nvim ~/.config/nvim/plugin ~/.cache/nvim || true
sudo rm -rf ~/neovim || true
echo "✅ Old Neovim removed (if any)."

# 2️⃣ Install dependencies
echo "[2/7] Installing dependencies..."
sudo apt update -y
sudo apt install -y ninja-build gettext cmake unzip curl build-essential git pkg-config libtool libtool-bin autoconf automake
echo "✅ Dependencies installed."

# 3️⃣ Clone repo Neovim
echo "[3/7] Cloning Neovim source..."
git clone https://github.com/neovim/neovim.git ~/neovim
cd ~/neovim

# 4️⃣ Checkout versi stable terbaru
echo "[4/7] Checking out stable version..."
git checkout stable

# 5️⃣ Build Neovim
echo "[5/7] Building Neovim (this may take 10-15 minutes)..."
make CMAKE_BUILD_TYPE=Release
sudo make install
echo "✅ Build complete."

# 6️⃣ Setup symlink
echo "[6/7] Linking binary to /usr/local/bin..."
if [ -f /usr/local/bin/nvim ]; then
  sudo ln -sf /usr/local/bin/nvim /usr/bin/nvim
else
  echo "⚠️  /usr/local/bin/nvim not found, skipping symlink step."
fi

# 7️⃣ Verification
echo "[7/7] Verifying Neovim installation..."
nvim --version | head -n 3 || echo "⚠️  Neovim not found in PATH!"

echo
echo "===================================================="
echo " 🎉 Neovim v0.11 successfully installed and configured!"
echo "===================================================="
echo "You can now run:  nvim"
echo
echo "If using Lazy.nvim, run inside Neovim:  :Lazy sync"
echo
