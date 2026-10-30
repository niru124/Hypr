#!/usr/bin/env bash
# Portable bootstrap for this Neovim (AstroNvim v5) configuration.
# Usage:
#   git clone <your-repo-url> ~/.config/nvim
#   ~/.config/nvim/install.sh [--yes] [--no-system] [--with-platformio]
#
# What it does:
#   1. Installs system dependencies (Neovim >= 0.10, git, build tools,
#      node, python, java, clang, rg, fd, lazygit, ranger, glow, clipboard
#      tools, trash-cli, a Nerd Font). Skipped with --no-system.
#   2. Installs aider + platformio via pipx (aider always, pio only with
#      --with-platformio).
#   3. Backs up any existing nvim config (only when run from outside it).
#   4. Headlessly installs all plugins, Mason tools (LSP/DAP/formatters)
#      and Treesitter parsers, so first interactive start is fully working.
set -euo pipefail

YES=0
WITH_SYSTEM=1
WITH_PLATFORMIO=0

for arg in "$@"; do
  case "$arg" in
    --yes) YES=1 ;;
    --no-system) WITH_SYSTEM=0 ;;
    --with-platformio) WITH_PLATFORMIO=1 ;;
    -h | --help)
      sed -n '2,12p' "$0"
      exit 0
      ;;
    *) echo "Unknown argument: $arg" >&2; exit 1 ;;
  esac
done

log() { printf '\033[1;34m[install]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[install]\033[0m WARNING: %s\n' "$*"; }
die() { printf '\033[1;31m[install]\033[0m ERROR: %s\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# 0. Locate this config (supports NVIM_APPNAME for side-by-side installs)
# ---------------------------------------------------------------------------
APPNAME="${NVIM_APPNAME:-nvim}"
if [ -n "${XDG_CONFIG_HOME:-}" ]; then
  CONFIG_DIR="$XDG_CONFIG_HOME/$APPNAME"
else
  CONFIG_DIR="$HOME/.config/$APPNAME"
fi
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ "$SCRIPT_DIR" != "$CONFIG_DIR" ]; then
  if [ -e "$CONFIG_DIR" ] && [ "$YES" -ne 1 ]; then
    read -r -p "Back up existing $CONFIG_DIR to ${CONFIG_DIR}-backup-$(date +%Y%m%d)? [Y/n] " ans
    case "$ans" in
      [nN]*) ;;
      *) mv "$CONFIG_DIR" "${CONFIG_DIR}-backup-$(date +%Y%m%d%H%M%S)" && log "Backed up old config." ;;
    esac
  elif [ -e "$CONFIG_DIR" ]; then
    mv "$CONFIG_DIR" "${CONFIG_DIR}-backup-$(date +%Y%m%d%H%M%S)" && log "Backed up old config."
  fi
  mkdir -p "$(dirname "$CONFIG_DIR")"
  cp -r "$SCRIPT_DIR" "$CONFIG_DIR" && log "Installed config to $CONFIG_DIR."
fi

# ---------------------------------------------------------------------------
# 1. System dependencies
# ---------------------------------------------------------------------------
have() { command -v "$1" >/dev/null 2>&1; }

install_system() {
  if [ "$(id -u)" -ne 0 ] && ! have sudo; then
    warn "Not root and no sudo; skipping system packages. Install manually: neovim>=0.10 git curl gcc make node npm python3 pip java clang rg fd lazygit ranger glow trash-cli wl-clipboard (or xclip)"
    return
  fi
  local SUDO=""
  [ "$(id -u)" -ne 0 ] && SUDO="sudo"

  if have pacman; then
    log "Detected Arch/CachyOS (pacman)."
    $SUDO pacman -Syu --needed --noconfirm \
      git curl base-devel neovim nodejs npm python python-pip pipx \
      jdk-openjdk maven gradle clang ripgrep fd lazygit ranger glow \
      trash-cli wl-clipboard
  elif have apt-get; then
    log "Detected Debian/Ubuntu (apt)."
    $SUDO apt-get update
    $SUDO apt-get install -y \
      git curl build-essential neovim nodejs npm python3 python3-pip python3-venv pipx \
      default-jdk maven gradle clang clangd clang-format ripgrep fd-find \
      ranger trash-cli xclip
    # lazygit + glow have no Ubuntu repo packages; install via go or direct download
    have lazygit || go_install_lazyglow
  elif have dnf; then
    log "Detected Fedora (dnf)."
    $SUDO dnf install -y \
      git curl gcc make neovim nodejs npm python3 python3-pip pipx \
      java-latest-openjdk-devel maven gradle clang clang-tools-extra \
      ripgrep fd-find lazygit ranger glow trash-cli wl-clipboard
  elif have brew; then
    log "Detected macOS (brew)."
    brew install git curl neovim node python pipx openjdk maven gradle \
      llvm ripgrep fd lazygit ranger glow trash-cli
  else
    warn "No supported package manager found. Install manually: neovim>=0.10 git curl gcc make node npm python3 pip java clang rg fd lazygit ranger glow trash-cli + a clipboard tool."
  fi
}

go_install_lazyglow() {
  have go || { warn "go not found; skipping lazygit/glow auto-install."; return; }
  log "Installing lazygit + glow via go."
  go install github.com/jesseduffield/lazygit@latest 2>/dev/null || true
  go install github.com/charmbracelet/glow@latest 2>/dev/null || true
}

if [ "$WITH_SYSTEM" -eq 1 ]; then
  install_system
else
  log "Skipping system packages (--no-system)."
fi

# ---------------------------------------------------------------------------
# 2. Neovim version floor (AstroNvim v5 needs >= 0.10)
# ---------------------------------------------------------------------------
if have nvim; then
  NVIM_VER="$(nvim --version | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1)"
  NVIM_MAJOR="${NVIM_VER%%.*}"
  NVIM_MINOR="${NVIM_VER##*.}"
  if [ "$NVIM_MAJOR" -eq 0 ] && [ "$NVIM_MINOR" -lt 10 ]; then
    die "Found Neovim $NVIM_VER, but AstroNvim v5 requires >= 0.10. Upgrade Neovim first."
  fi
  log "Neovim $NVIM_VER OK."
else
  die "nvim not found even after system install. Install Neovim >= 0.10 manually."
fi

# ---------------------------------------------------------------------------
# 3. Nerd Font (needed for icons)
# ---------------------------------------------------------------------------
if ! fc-list 2>/dev/null | grep -qi "nerd"; then
  log "Installing CaskaydiaCove Nerd Font."
  mkdir -p "$HOME/.local/share/fonts"
  curl -sSL -o /tmp/CaskaydiaCove.zip \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCove.zip" \
    && unzip -oq /tmp/CaskaydiaCove.zip -d "$HOME/.local/share/fonts/CascadiaCoveNF" \
    && fc-cache -f "$HOME/.local/share/fonts" >/dev/null \
    && log "Nerd Font installed." \
    || warn "Font download failed; install any Nerd Font manually."
else
  log "Nerd Font already present."
fi

# ---------------------------------------------------------------------------
# 4. Python tools via pipx (aider; platformio optional)
# ---------------------------------------------------------------------------
if ! have pipx; then
  warn "pipx not found; skipping aider/platformio. Install pipx, then: pipx install aider-chat [platformio]"
else
  pipx ensurepath >/dev/null 2>&1 || true
  if ! have aider; then
    log "Installing aider-chat via pipx."
    pipx install aider-chat 2>/dev/null && log "aider installed (set your model API key to use it)." \
      || warn "aider install failed; run: pipx install aider-chat"
  else
    log "aider already present."
  fi
  if [ "$WITH_PLATFORMIO" -eq 1 ] && ! have pio; then
    log "Installing platformio via pipx."
    pipx install platformio 2>/dev/null && log "platformio installed." \
      || warn "platformio install failed; run: pipx install platformio"
  fi
fi

# ---------------------------------------------------------------------------
# 5. Headless first-run provisioning: plugins + Mason + Treesitter
# ---------------------------------------------------------------------------
export NVIM_APPNAME="$APPNAME"
log "Installing plugins (lazy.nvim sync, this takes a while)..."
nvim --headless "+Lazy! sync" +qa 2>&1 | grep -iE "error|failed|E[0-9]+" | head -n 5 || true

log "Installing Mason tools (LSP servers, DAP adapters, formatters)..."
nvim --headless "+MasonToolsInstallSync" +qa 2>&1 | grep -iE "error|failed|E[0-9]+" | head -n 5 || true

log "Installing Treesitter parsers..."
nvim --headless "+TSUpdateSync" +qa 2>&1 | grep -iE "^Error|E[0-9]+" | head -n 5 || true

log "Smoke test: opening lua/python/markdown buffers..."
nvim --headless \
  -c "edit $CONFIG_DIR/lua/polish.lua" \
  -c "lua assert(vim.bo.filetype == 'lua', 'lua ft failed')" \
  -c "qa!" 2>&1 | grep -iE "^Error|E[0-9]+" | head -n 5 || true

log "Done. Start with: nvim"
log "Optional: :Mason to inspect tools, :Lazy sync to update, :checkhealth to diagnose."
