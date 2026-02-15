#!/bin/bash

echo '
  ___  ___ _  _   _   _    ___ 
 |   \| __| \| | /_\ | |  |_ _|
 | |) | _|| .` |/ _ \| |__ | | 
 |___/|___|_|\_/_/ \_\____|___|                              
'
echo 'Setting up your new device...'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `setup.sh` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# install homebrew if it does not exist
IF_HOMEBREW=$(which brew)
if [ -z "$IF_HOMEBREW" ]; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to PATH for this session (Apple Silicon)
  if [ -d "/opt/homebrew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
else
  echo "Homebrew already installed"
fi

# Install gh CLI first (needed to clone dotfiles)
echo "Installing GitHub CLI..."
brew install gh

# Check GitHub CLI authentication
if ! gh auth status &>/dev/null; then
  echo ""
  echo "⚠️  GitHub CLI not authenticated."
  echo "Please login to GitHub to clone the dotfiles repository."
  echo ""
  gh auth login
fi

# Verify authentication worked
if ! gh auth status &>/dev/null; then
  echo "❌ GitHub authentication failed. Exiting."
  exit 1
fi

# setup directory for github and clone dotfiles
echo "Cloning dotfiles repository..."
mkdir -p ~/github.com/josefaidt
cd ~/github.com/josefaidt
gh repo clone dotfiles

cd dotfiles

# Now install everything else from Brewfile
echo "Installing packages from Brewfile..."
brew bundle

# change default shell to fish
echo "Setting fish as default shell..."
if ! fgrep -q "/opt/homebrew/bin/fish" /etc/shells; then
  echo "/opt/homebrew/bin/fish" | sudo tee -a /etc/shells
fi
if [ "$SHELL" != "/opt/homebrew/bin/fish" ]; then
  chsh -s /opt/homebrew/bin/fish
fi

# Configure macOS defaults
echo "Configuring macOS defaults..."

# show the ~/Library folder
chflags nohidden ~/Library

# show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# never bounce the dock
defaults write com.apple.dock no-bouncing -bool TRUE;

# automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# don't automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Stow configuration files
echo "Deploying configuration files..."

# setup global gitignore
stow git
git config --global core.excludesfile ~/.gitignore_global

xdg-config-stow fish
xdg-config-stow nvim
xdg-config-stow ghostty
xdg-config-stow zellij

# Symlink starship config
if [ -f ~/.config/starship.toml ]; then
  echo "Starship config already exists, skipping..."
else
  ln -s $(pwd)/.config/starship.toml ~/.config/starship.toml
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal (or run: exec fish)"
echo "  2. Open Neovim (nvim will auto-install plugins on first run)"
echo "  3. Enjoy your new setup!"
