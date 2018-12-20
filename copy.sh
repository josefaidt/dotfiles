#!/bin/bash

echo "🚀 Preparing for takeoff..."

# 1. Assign common vars

HOME="$HOME"
CONFIG=".config"

# 2. Copy vim files

VIM=".vim"
if [ -d "$HOME/$VIM" ]; then
  echo "🗄️ vim directory exists, copying..."
  if [ ! -d "./vim" ]; then
    mkdir vim
  fi
  # Copy vim files
  cp -r $HOME/.vim/ ./vim
  cp $HOME/.vimrc ./vim
fi

# 3. Copy fish files

FISH="fish"
FISHPATH="$HOME/$CONFIG/$FISH"
if [ -n "$FISHPATH/config.fish" ]; then
  echo "🗄️ fish file exists, copying..."
  if [ ! -d "./fish" ]; then
    mkdir fish
  fi

  cp -r $FISHPATH/config.fish ./fish
fi

# 4. Copy tmux files

if [ -n $HOME/.tmux.conf ]; then
  echo "🗄️ tmux file exists, copying..."
  if [ ! -d "./tmux" ]; then
    mkdir tmux
  fi

  cp $HOME/.tmux.conf ./tmux
fi

# Cleanup
# echo "🧹 Clean up time!"

# Fin
echo '🏁 Finished!'