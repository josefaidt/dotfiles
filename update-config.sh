#!/bin/bash

echo '
  ___  ___ _  _   _   _    ___ 
 |   \| __| \| | /_\ | |  |_ _|
 | |) | _|| .` |/ _ \| |__ | | 
 |___/|___|_|\_/_/ \_\____|___|                              
'
echo 'Updating configs...'

# start copying config files
TEMP_DIR=$(mktemp -d)
# download dotfiles repo
git clone git@github.com:josefaidt/dotfiles.git $TEMP_DIR
# copy to ~/.config
rsync --progress --recursive $TEMP_DIR/.config/ ~/.config