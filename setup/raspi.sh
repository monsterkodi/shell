#!/usr/bin/env bash

# ssh-keygen
# cat ~/.ssh/id_rsa.pub
# cd ~
# git clone git@github.com:monsterkodi/shell.git

sudo adduser pi staff

cd ~/shell/setup

./apt.sh

wget http://node-arm.herokuapp.com/node_latest_armhf.deb 
sudo dpkg -i node_latest_armhf.deb

./npm.sh
./gem.sh
./pip.sh

rm -f ~/.bashrc
ln -s ~/shell/bash/linux.bashrc ~/.bashrc
rm -f ~/.profile
ln -s ~/shell/bash/profile ~/.profile
ln -s ~/shell/fish ~/.config/
ln -s ~/shell/git/gitconfig ~/.gitconfig

chsh -s /usr/bin/fish
