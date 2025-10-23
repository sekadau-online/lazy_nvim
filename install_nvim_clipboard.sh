#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ------------------------------------------------------------
# Robust Neovim v0.11+ Build, Clipboard & Auto-Update Installer
# - Handles detached HEAD, branch creation, resets to origin
# - Auto-detect package manager (apt/dnf/pacman/zypper)
# - Options: --branch, --dir, --no-deps, --no-sudo, --keep-build
# - Safe: uses make distclean and reset but doesn't delete user config
# ------------------------------------------------------------

# Defaults (can be overridden by CLI or env)
NVIM_DIR="${NVIM_DIR:-${HOME}/neovim}"
NVIM_REMOTE="${NVIM_REMOTE:-https://github.com/neovim/neovim.git}"
NVIM_BRANCH="${NVIM_BRANCH:-stable}"
NO_DEPS=false
NO_SUDO=false
KEEP_BUILD=false
BUILD_JOBS="$(nproc || echo 2)"

log()   { printf "\e[1;34m[INFO]\e[0m %s\n" "$*"; }
warn()  { printf "\e[1;33m[WARN]\e[0m %s\n" "$*"; }
err()   { printf "\e[1;31m[ERR]\e[0m %s\n" "$*"; }
ok()    { printf "\e[1;32m[OK]\e[0m %s\n" "$*"; }

usage() {
  cat <<EOF
Usage: $0 [options]

Options:
  --dir PATH        Install directory (default: $NVIM_DIR)
  --branch NAME     Git branch to use (default: $NVIM_BRANCH)
  --no-deps         Skip installing system dependencies
  --no-sudo         Do not use sudo (assume you have write perms)
  --keep-build      Keep build artifacts between runs (skip make distclean)
  -h|--help         Show this help
EOF
  exit 1
}

# Parse CLI args
while (( $# )); do
  case "$1" in
    --dir) NVIM_DIR="$2"; shift 2;;
    --branch) NVIM_BRANCH="$2"; shift 2;;
    --no-deps) NO_DEPS=true; shift;;
    --no-sudo) NO_SUDO=true; shift;;
    --keep-build) KEEP_BUILD=true; shift;;
    -h|--help) usage;;
    *) warn "Unknown option: $1"; usage;;
  esac
done

SUDO_CMD="sudo"
if $NO_SUDO; then
  SUDO_CMD=""
fi

# Detect package manager
detect_pkg_mgr() {
  if command -v apt-get >/dev/null 2>&1; then echo "apt"; return; fi
  if command -v dnf >/dev/null 2>&1; then echo "dnf"; return; fi
  if command -v pacman >/dev/null 2>&1; then echo "pacman"; return; fi
  if command -v zypper >/dev/null 2>&1; then echo "zypper"; return; fi
  echo "unknown"
}

PKG_MGR="$(detect_pkg_mgr)"

install_packages() {
  local pkgs=(ninja-build gettext cmake unzip curl build-essential git pkg-config \
    libtool libtool-bin autoconf automake libevent-dev libuv1-dev \
    libx11-dev libxtst-dev libxt-dev libsm-dev libice-dev \
    xclip xsel wl-clipboard)
  log "Detected package manager: $PKG_MGR"

  if $NO_DEPS; then
    warn "Skipping dependency installation (--no-deps)"
    return 0
  fi

  case "$PKG_MGR" in
    apt)
      $SUDO_CMD apt update -y
      # adapt package list for apt (build-essential covers many)
      $SUDO_CMD apt install -y "${pkgs[@]}" || {
        warn "apt install failed; you may need to install dependencies manually."
      }
      ;;
    dnf)
      $SUDO_CMD dnf install -y cmake gcc-c++ make ninja-build git pkgconfig \
        libtool autoconf automake libevent-devel libuv-devel libX11-devel \
        libXrandr-devel libXcursor-devel libXfixes-devel xclip xsel wl-clipboard || {
        warn "dnf install failed; please install equivalent packages for your distro."
      }
      ;;
    pacman)
      $SUDO_CMD pacman -Syu --noconfirm
      $SUDO_CMD pacman -S --noconfirm base-devel cmake ninja git pkgconf libtool \
        libx11 xclip xsel wl-clipboard || {
        warn "pacman install failed."
      }
      ;;
    zypper)
      $SUDO_CMD zypper refresh
      $SUDO_CMD zypper install -y gcc-c++ make cmake git ninja libtool autoconf \
        automake libX11-devel xclip xsel wl-clipboard || {
        warn "zypper install failed."
      }
      ;;
    *)
      warn "Unsupported or unknown package manager. Please install dependencies manually:"
      printf '%s\n' "${pkgs[@]}"
      ;;
  esac
}

# Ensure directory exists
ensure_dir() {
  mkdir -p "$NVIM_DIR"
}

# Clone or update repo robustly
clone_or_update() {
  if [ -d "$NVIM_DIR/.git" ]; then
    log "Found existing git repo at $NVIM_DIR — fetching origin..."
    cd "$NVIM_DIR"
    git remote set-url origin "$NVIM_REMOTE" || true
    git fetch --all --prune
    # If working tree is detached, try checking out desired branch or create it from origin
    if git symbolic-ref -q --short HEAD >/dev/null 2>&1; then
      CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
      log "Current branch: $CURRENT_BRANCH"
    else
      warn "Repository is in detached HEAD state."
      CURRENT_BRANCH=""
    fi

    # Attempt to checkout branch; if fails, create it to track origin/<branch>
    if git show-ref --verify --quiet "refs/heads/$NVIM_BRANCH"; then
      git checkout "$NVIM_BRANCH"
    else
      # If local branch doesn't exist, try create tracking branch from origin
      if git ls-remote --exit-code --heads origin "$NVIM_BRANCH" >/dev/null 2>&1; then
        git checkout -B "$NVIM_BRANCH" "origin/$NVIM_BRANCH"
      else
        # fallback to main or stable remote
        warn "Remote branch origin/$NVIM_BRANCH not found — attempting 'stable' or 'main'"
        if git ls-remote --exit-code --heads origin stable >/dev/null 2>&1; then
          NVIM_BRANCH="stable"
          git checkout -B stable "origin/stable"
        elif git ls-remote --exit-code --heads origin main >/dev/null 2>&1; then
          NVIM_BRANCH="main"
          git checkout -B main "origin/main"
        else
          # if nothing, keep current commit but continue
          warn "No suitable remote branch found. Staying on current commit."
        fi
      fi
    fi

    # Reset hard to remote branch if available
    if git rev-parse --verify "origin/$NVIM_BRANCH" >/dev/null 2>&1; then
      git reset --hard "origin/$NVIM_BRANCH"
      git clean -fdx || true
    else
      warn "origin/$NVIM_BRANCH not available; local state preserved."
    fi
  else
    log "Cloning Neovim into $NVIM_DIR..."
    git clone --depth=1 --branch "$NVIM_BRANCH" "$NVIM_REMOTE" "$NVIM_DIR" || {
      warn "Shallow clone failed; attempting full clone..."
      git clone "$NVIM_REMOTE" "$NVIM_DIR"
      cd "$NVIM_DIR"
      git checkout "$NVIM_BRANCH" || true
    }
  fi
  ok "Repository ready (branch: $NVIM_BRANCH)."
}

# Build Neovim
build_neovim() {
  cd "$NVIM_DIR"
  # Clean previous build unless user wants to keep artifacts
  if ! $KEEP_BUILD; then
    log "Cleaning previous build artifacts (make distclean) — ignoring errors..."
    make distclean >/dev/null 2>&1 || true
  else
    log "--keep-build set, skipping make distclean"
  fi

  log "Configuring & building Neovim (Release, jobs=$BUILD_JOBS)..."
  # Use make default target with CMAKE_BUILD_TYPE=Release
  make CMAKE_BUILD_TYPE=Release -j"$BUILD_JOBS"
  ok "Build finished."
}

# Install Neovim
install_neovim() {
  cd "$NVIM_DIR"
  log "Installing Neovim to system (may require sudo)..."
  if [ -n "$SUDO_CMD" ]; then
    $SUDO_CMD make install
  else
    make install
  fi
  ok "Installed Neovim."
}

# Ensure symlink
ensure_symlink() {
  # Prefer /usr/local/bin -> /usr/bin for compatibility
  local src="/usr/local/bin/nvim"
  local dest="/usr/bin/nvim"
  if [ -f "$src" ]; then
    if [ -n "$SUDO_CMD" ]; then
      $SUDO_CMD ln -sf "$src" "$dest"
    else
      ln -sf "$src" "$dest"
    fi
    ok "Symlink ensured: $dest → $src"
  else
    warn "$src not found; skipping symlink."
  fi
}

# Clipboard detection
ensure_clipboard() {
  if command -v wl-copy >/dev/null 2>&1; then
    ok "Wayland clipboard (wl-clipboard) available."
    return
  fi
  if command -v xclip >/dev/null 2>&1; then
    ok "xclip available."
    return
  fi
  if command -v xsel >/dev/null 2>&1; then
    ok "xsel available."
    return
  fi

  warn "No clipboard utility found. Attempting to install xclip/xsel..."
  if $NO_DEPS; then
    warn "--no-deps set, not installing clipboard utilities."
  else
    case "$PKG_MGR" in
      apt) $SUDO_CMD apt install -y xclip || true;;
      dnf) $SUDO_CMD dnf install -y xclip || true;;
      pacman) $SUDO_CMD pacman -S --noconfirm xclip || true;;
      zypper) $SUDO_CMD zypper install -y xclip || true;;
      *) warn "Please install xclip/xsel/wl-clipboard manually.";;
    esac
  fi
}

# Version & clipboard check
post_install_checks() {
  log "Neovim version & clipboard check:"
  if command -v nvim >/dev/null 2>&1; then
    nvim --version | head -n 5
    if nvim --version | grep -q '\+clipboard'; then
      ok "Neovim compiled with clipboard support (+clipboard)."
    else
      warn "Neovim missing +clipboard. You may need libX11-dev etc. before building."
    fi
  else
    err "nvim binary not found in PATH. Installation may have failed."
  fi
  log "Inside nvim you can verify: :echo has('clipboard')  and  :checkhealth clipboard"
}

# Trap for cleanup (if needed)
on_exit() {
  local rc=$?
  if [ $rc -eq 0 ]; then
    ok "Script completed successfully."
  else
    err "Script exited with code $rc."
  fi
}
trap on_exit EXIT

# -------------------------
# Execution flow
# -------------------------
log "Starting Neovim build/install script"
log "Target dir: $NVIM_DIR"
log "Target branch: $NVIM_BRANCH"
log "NO_DEPS: $NO_DEPS  NO_SUDO: $NO_SUDO  KEEP_BUILD: $KEEP_BUILD"

ensure_dir
install_packages
clone_or_update
build_neovim
install_neovim
ensure_symlink
ensure_clipboard
post_install_checks

# Final friendly message
echo
echo "===================================================="
echo " 🎉 Neovim $(nvim --version 2>/dev/null | head -n1 | awk '{print $2}') - installation complete (if no errors above)."
echo " Tips:"
echo "   • To update Neovim: re-run this script (it will fetch & reset to origin/$NVIM_BRANCH)."
echo "   • To change branch: run with --branch <name>"
echo "   • To skip deps on minimal systems: --no-deps"
echo "===================================================="
