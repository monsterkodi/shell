#!/usr/bin/env bash

# git clone git@github.com:monsterkodi/shell.git

mkdir -pv ~/.config

./brew.sh

ln -s ~/shell/bash/mac.bashrc ~/.bashrc
ln -s ~/shell/bash/profile ~/.profile
ln -s ~/shell/fish ~/.config/
ln -s ~/shell/git/gitconfig ~/.gitconfig

./npm.sh
./gem.sh
./pip.sh
./defaults.sh
