#!/bin/bash

echo 'Setting up your new device...'

# install homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# install the basics
brew install \
  fish \
  node \
  yarn \
  tmux

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
  spectacle \
  github \
  vlc \
  postman \
  graphql-playground

# change default shell to fish
sudo echo /usr/local/bin/fish >> /etc/shells
chsh -s /usr/local/bin/fish
cp -r ./fish ~/.config

# copy other dotfiles
cp ./tmux/.tmux.conf ~
mkdir ~/.vim
cp -r ./vim/colors ~/.vim
cp ./vim/.vimrc ~

# reload config
# source ~/.config/fish/fish.config

# install ESLint and other npm packages (uses custom fish function)
yarn global add \
  eslint babel-eslint eslint-loader \
  prettier eslint-config-prettier eslint-plugin-prettier \
  eslint-config-standard eslint-plugin-standard \
  eslint-plugin-node \
  eslint-plugin-jsx-a11y \
  eslint-plugin-promise \
  eslint-plugin-import \
  eslint-plugin-react
cp ./.eslintrc.js ~/.config