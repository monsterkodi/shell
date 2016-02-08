#!/usr/bin/env bash

# ssh-keygen
# cat ~/.ssh/id_rsa.pub
# cd ~
# git clone git@github.com:monsterkodi/shell.git

cd ~/shell/setup

./apt.sh

chsh -s /usr/bin/fish

ln -s ~/shell/bash/linux.bashrc ~/.bashrc
ln -s ~/shell/bash/profile ~/.profile
ln -s ~/shell/fish ~/.config/
ln -s ~/shell/git/gitconfig ~/.gitconfig

curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -e

./npm.sh

# sudo chown -R kodi:kodi ~/.npm/*

./gem.sh
./pip.sh

