#!/bin/bash

echo 'Setting up your new device...'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `setup.sh` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# install homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# install the basics
brew install \
  fish \
  node \
  yarn \
  tmux \
  ranger \
  tree \
  neovim

# change default shell to /usr/local/bin/fish
# install Fisher and Bass (for nvm, if we need it later)
curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish
fisher add edc/bass

# install GUI applications
brew tap caskroom/cask
brew cask install \
  google-chrome \
  brave-browser \
  firefox \
  visual-studio-code \
  sublime-text \
  spotify \
  spotmenu \
  docker \
  github \
  vlc \
  postman \
  graphql-playground

# change default shell to fish
sudo echo /usr/local/bin/fish >> /etc/shells
chsh -s /usr/local/bin/fish
cp -r ./fish ~/.config

# copy other dotfiles
cp ./.tmux.conf ~
mkdir ~/.vim
cp -r ./.vim/colors ~/.vim
cp ./.vimrc ~
