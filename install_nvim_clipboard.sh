#!/usr/bin/env bash
set -e

echo "===================================================="
echo " ⚙️  Neovim v0.11+ Build, Clipboard & Auto-Update Installer"
echo "===================================================="
sleep 1

NVIM_DIR=~/neovim

# 1️⃣ Bersihkan sisa build lama (tanpa hapus config user)
echo "[1/9] Cleaning previous Neovim build cache..."
if [ -d "$NVIM_DIR" ]; then
  cd "$NVIM_DIR"
  make distclean || true
  git reset --hard HEAD || true
  git clean -fdx || true
  echo "✅ Old build cache cleaned."
else
  echo "ℹ️  No previous build found, skipping."
fi

# 2️⃣ Install dependencies (build + clipboard + runtime)
echo "[2/9] Installing dependencies..."
sudo apt update -y
sudo apt install -y \
  ninja-build gettext cmake unzip curl build-essential git pkg-config \
  libtool libtool-bin autoconf automake libevent-dev libuv1-dev \
  libx11-dev libxtst-dev libxt-dev libsm-dev libice-dev \
  xclip xsel wl-clipboard
echo "✅ Dependencies installed."

# 3️⃣ Clone or update repo Neovim
echo "[3/9] Cloning or updating Neovim source..."
if [ -d "$NVIM_DIR/.git" ]; then
  cd "$NVIM_DIR"
  git fetch origin
  git checkout stable
  git pull --rebase
else
  git clone https://github.com/neovim/neovim.git "$NVIM_DIR"
  cd "$NVIM_DIR"
  git checkout stable
fi
echo "✅ Neovim source ready."

# 4️⃣ Build Neovim (release mode)
echo "[4/9] Building Neovim (Release mode)..."
make distclean || true
make CMAKE_BUILD_TYPE=Release -j"$(nproc)"
echo "✅ Build complete."

# 5️⃣ Install Neovim
echo "[5/9] Installing Neovim..."
sudo make install
echo "✅ Installed to /usr/local/bin/nvim"

# 6️⃣ Symlink to /usr/bin
echo "[6/9] Ensuring symlink in /usr/bin..."
if [ -f /usr/local/bin/nvim ]; then
  sudo ln -sf /usr/local/bin/nvim /usr/bin/nvim
  echo "✅ Symlink created: /usr/bin/nvim → /usr/local/bin/nvim"
else
  echo "⚠️  /usr/local/bin/nvim not found!"
fi

# 7️⃣ Clipboard auto detection
echo "[7/9] Verifying clipboard utilities..."
if command -v wl-copy >/dev/null 2>&1; then
  echo "✅ Wayland clipboard available (wl-clipboard)."
elif command -v xclip >/dev/null 2>&1; then
  echo "✅ X11 clipboard available (xclip)."
elif command -v xsel >/dev/null 2>&1; then
  echo "✅ X11 clipboard available (xsel)."
else
  echo "⚠️  No clipboard provider found, installing xclip..."
  sudo apt install -y xclip
fi

# 8️⃣ Version check & clipboard confirmation
echo "[8/9] Verifying Neovim installation..."
nvim --version | head -n 10
if nvim --version | grep -q '\+clipboard'; then
  echo "✅ Clipboard support is active!"
else
  echo "❌ Clipboard support missing — ensure libx11-dev etc. are installed."
fi

# 9️⃣ Finish message
echo
echo "===================================================="
echo " 🎉 Neovim $(nvim --version | head -n 1 | awk '{print $2}') installed successfully!"
echo "===================================================="
echo "🧩 To verify inside Neovim:"
echo "  :echo has('clipboard')  → should return 1"
echo "  :checkhealth clipboard"
echo
echo "🔁 To update Neovim in the future, just rerun this script!"
echo "===================================================="
echo
