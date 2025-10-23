#!/usr/bin/env bash
set -e

echo "===================================================="
echo " ⚙️  Neovim Build & Clipboard Support Installer (v0.11+)"
echo "===================================================="
sleep 1

# 1️⃣ Bersihkan sisa instalasi lama
echo "[1/8] Cleaning old Neovim installations..."
sudo rm -f /usr/bin/nvim /usr/local/bin/nvim || true
sudo rm -rf ~/.local/share/nvim ~/.config/nvim/plugin ~/.cache/nvim || true
sudo rm -rf ~/neovim || true
echo "✅ Old Neovim removed (if any)."

# 2️⃣ Install dependencies (build + clipboard)
echo "[2/8] Installing dependencies..."
sudo apt update -y
sudo apt install -y \
  ninja-build gettext cmake unzip curl build-essential git pkg-config \
  libtool libtool-bin autoconf automake libevent-dev libuv1-dev \
  libx11-dev libxtst-dev libxt-dev libsm-dev libice-dev \
  xclip xsel wl-clipboard
echo "✅ Dependencies installed."

# 3️⃣ Clone repo Neovim
echo "[3/8] Cloning Neovim source..."
git clone https://github.com/neovim/neovim.git ~/neovim
cd ~/neovim

# 4️⃣ Checkout stable version
echo "[4/8] Checking out stable version..."
git checkout stable

# 5️⃣ Build Neovim
echo "[5/8] Building Neovim (this may take 5–15 min)..."
make distclean || true
make CMAKE_BUILD_TYPE=Release
sudo make install
echo "✅ Build complete."

# 6️⃣ Setup symlink
echo "[6/8] Linking binary to /usr/local/bin..."
if [ -f /usr/local/bin/nvim ]; then
  sudo ln -sf /usr/local/bin/nvim /usr/bin/nvim
else
  echo "⚠️  /usr/local/bin/nvim not found, skipping symlink step."
fi

# 7️⃣ Clipboard auto setup
echo "[7/8] Configuring system clipboard integration..."
if command -v xclip >/dev/null 2>&1; then
  echo "✅ xclip found — clipboard integration enabled."
elif command -v wl-copy >/dev/null 2>&1; then
  echo "✅ wl-clipboard found — Wayland clipboard integration enabled."
else
  echo "⚠️  No clipboard bridge detected. Installing xclip..."
  sudo apt install -y xclip
fi

# 8️⃣ Verification
echo "[8/8] Verifying Neovim installation..."
nvim --version | head -n 10

if nvim --version | grep -q '\+clipboard'; then
  echo "✅ Clipboard support is active!"
else
  echo "❌ Clipboard support missing — check dependencies above."
fi

echo
echo "===================================================="
echo " 🎉 Neovim v$(nvim --version | head -n 1 | awk '{print $2}') successfully installed!"
echo "===================================================="
echo "🧩 To verify clipboard inside Neovim:"
echo "  :echo has('clipboard')  → should return 1"
echo "  :checkhealth clipboard"
echo
echo "If using Lazy.nvim, open Neovim and run:  :Lazy sync"
echo
