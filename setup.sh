#!/bin/bash

echo '
  ___  ___ _  _   _   _    ___
 |   \| __| \| | /_\ | |  |_ _|
 | |) | _|| .` |/ _ \| |__ | |
 |___/|___|_|\_/_/ \_\____|___|
'

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

DOTFILES_DIR="$HOME/github.com/josefaidt/dotfiles"

step() { echo ""; echo "▶ $*"; }
info() { echo "  $*"; }

# ---------------------------------------------------------------------------
# Mode detection
# ---------------------------------------------------------------------------
# Pass --install or --update to force a mode.
# Without a flag: update if the dotfiles repo already exists, install otherwise.

MODE=""
for arg in "$@"; do
  case "$arg" in
    --install) MODE="install" ;;
    --update)  MODE="update"  ;;
  esac
done

if [ -z "$MODE" ]; then
  if [ -d "$DOTFILES_DIR/.git" ]; then
    MODE="update"
  else
    MODE="install"
  fi
fi

echo "Running in $MODE mode..."

# ---------------------------------------------------------------------------
# Shared: ensure sudo stays alive for the duration of the script
# ---------------------------------------------------------------------------

sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
SUDO_PID=$!
trap 'kill $SUDO_PID 2>/dev/null' EXIT

# ---------------------------------------------------------------------------
# Shared: Homebrew
# ---------------------------------------------------------------------------

ensure_homebrew() {
  if ! command -v brew &>/dev/null; then
    step "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ -d "/opt/homebrew" ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  else
    info "Homebrew already installed"
  fi
}

# ---------------------------------------------------------------------------
# Shared: stow all configs
# ---------------------------------------------------------------------------

stow_all() {
  step "Deploying configuration files..."
  cd "$DOTFILES_DIR"
  stow git
  git config --global core.excludesfile ~/.gitignore_global
  xdg-config-stow fish
  xdg-config-stow nvim
  xdg-config-stow ghostty
  xdg-config-stow zellij
  stow claude
}

# ---------------------------------------------------------------------------
# Shared: bun globals
# ---------------------------------------------------------------------------

install_bun_globals() {
  step "Installing bun globals (oxfmt, oxlint)..."
  if ! command -v bun &>/dev/null; then
    curl -fsSL https://bun.com/install | bash
    # Add bun to PATH for the rest of this session
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
  else
    info "bun already installed ($(bun --version))"
  fi
  bun install --global oxfmt
  bun install --global oxlint
}

# ---------------------------------------------------------------------------
# INSTALL
# ---------------------------------------------------------------------------

run_install() {
  ensure_homebrew

  step "Installing GitHub CLI..."
  brew install gh

  step "Authenticating with GitHub..."
  if ! gh auth status &>/dev/null; then
    echo ""
    echo "⚠️  GitHub CLI not authenticated. Please log in."
    gh auth login
  fi
  if ! gh auth status &>/dev/null; then
    echo "❌ GitHub authentication failed. Exiting."
    exit 1
  fi

  step "Cloning dotfiles repository..."
  mkdir -p "$HOME/github.com/josefaidt"
  cd "$HOME/github.com/josefaidt"
  gh repo clone dotfiles
  cd dotfiles

  step "Installing packages from Brewfile..."
  brew bundle

  step "Setting fish as default shell..."
  if ! fgrep -q "/opt/homebrew/bin/fish" /etc/shells; then
    echo "/opt/homebrew/bin/fish" | sudo tee -a /etc/shells
  fi
  if [ "$SHELL" != "/opt/homebrew/bin/fish" ]; then
    chsh -s /opt/homebrew/bin/fish
  fi

  step "Configuring macOS defaults..."
  chflags nohidden ~/Library
  defaults write com.apple.finder AppleShowAllFiles -bool true
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  defaults write com.apple.dock no-bouncing -bool TRUE
  defaults write com.apple.dock autohide -bool true
  defaults write com.apple.dock mru-spaces -bool false

  step "Activating git hooks..."
  cd "$DOTFILES_DIR"
  git config core.hooksPath .githooks

  stow_all
  install_bun_globals

  echo ""
  echo "✅ Install complete!"
  echo ""
  echo "Next steps:"
  echo "  1. Restart your terminal (or run: exec fish)"
  echo "  2. Open Neovim (nvim will auto-install plugins on first run)"
  echo "  3. Enjoy your new setup!"
}

# ---------------------------------------------------------------------------
# UPDATE
# ---------------------------------------------------------------------------

run_update() {
  ensure_homebrew

  step "Pulling latest dotfiles..."
  cd "$DOTFILES_DIR"
  ORIG_HEAD=$(git rev-parse HEAD)
  git pull --rebase

  step "Updating Homebrew packages..."
  brew bundle --no-lock
  brew upgrade
  brew cleanup

  step "Re-stowing changed configs..."
  cd "$DOTFILES_DIR"
  CHANGED=$(git diff-tree -r --name-only --no-commit-id "$ORIG_HEAD" HEAD 2>/dev/null || echo "")
  if [ -n "$CHANGED" ]; then
    echo "$CHANGED" | bash .githooks/restow
  else
    info "No config changes detected, stowing all to be safe..."
    stow_all
  fi

  install_bun_globals

  echo ""
  echo "✅ Update complete!"
}

# ---------------------------------------------------------------------------
# Dispatch
# ---------------------------------------------------------------------------

case "$MODE" in
  install) run_install ;;
  update)  run_update  ;;
esac
