#!/usr/bin/env bash
set -e

echo "=============================================="
echo " 🛠️  Building Neovim v0.11 from source safely"
echo "=============================================="
sleep 1

# 1️⃣ Pasang semua dependensi
echo "[1/5] Installing dependencies..."
sudo apt update -y
sudo apt install -y ninja-build gettext cmake unzip curl build-essential git

# 2️⃣ Hapus build lama (jika ada)
if [ -d "$HOME/neovim" ]; then
  echo "[2/5] Removing old Neovim source..."
  rm -rf "$HOME/neovim"
fi

# 3️⃣ Clone repo Neovim
echo "[3/5] Cloning Neovim repository..."
git clone https://github.com/neovim/neovim.git "$HOME/neovim"
cd "$HOME/neovim"

# 4️⃣ Checkout versi stable terbaru
echo "[4/5] Checking out stable branch..."
git checkout stable

# 5️⃣ Compile dan install
echo "[5/5] Building and installing Neovim..."
make CMAKE_BUILD_TYPE=Release
sudo make install

# 6️⃣ Verifikasi hasil
echo
echo "=============================================="
echo " ✅ Installation complete!"
echo "=============================================="
nvim --version | head -n 3
echo
echo "You can now run 'nvim' anywhere 🚀"
