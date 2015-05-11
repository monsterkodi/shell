#!/usr/bin/env bash

mkdir -pv ~/.config

./brew.sh

cd ~
git clone https://github.com/monsterkodi/shell.git

ln -s ~/shell/bash/mac.bashrc ~/.bashrc
ln -s ~/shell/bash/profile ~/.profile
ln -s ~/shell/fish ~/.config/
ln -s ~/shell/git/gitconfig ~/.gitconfig

./npm.sh
./gem.sh
./pip.sh
./defaults.sh
