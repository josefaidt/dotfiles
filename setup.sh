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
else
  echo "Homebrew already installed"
fi

# install from Brewfile
brew bundle

# change default shell to fish
if ! fgrep -q "/opt/homebrew/bin/fish" /etc/shells; then
  echo "/opt/homebrew/bin/fish" | sudo tee -a /etc/shells
fi
if [ "$SHELL" != "/opt/homebrew/bin/fish" ]; then
  chsh -s /opt/homebrew/bin/fish
fi

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

# don’t automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# setup directory for github
mkdir -p ~/github.com/josefaidt
cd ~/github.com/josefaidt
gh repo clone dotfiles

cd dotfiles

# setup global gitignore
stow git
git config --global core.excludesfile ~/.gitignore_global

xdg-config-stow fish
xdg-config-stow nvim
xdg-config-stow ghostty
xdg-config-stow zellij

ln -s $(pwd)/.config/starship.toml ~/.config/starship.toml
