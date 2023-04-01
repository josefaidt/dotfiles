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

# install the basics
brew install \
  fish \
  tmux \
  ranger \
  tree \
  fnm \
  gh \

# change default shell to fish
if ! fgrep -q "/opt/homebrew/bin/fish" /etc/shells; then
  echo "/opt/homebrew/bin/fish" | sudo tee -a /etc/shells
fi
if [ "$SHELL" != "/opt/homebrew/bin/fish" ]; then
  chsh -s /opt/homebrew/bin/fish
fi


# start copying config files
TEMP_DIR=$(mktemp -d)
# download dotfiles repo
git clone git@github.com:josefaidt/dotfiles.git $TEMP_DIR
# copy to ~/.config
rsync -a $TEMP_DIR/.config ~/.config
