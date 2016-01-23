#!/usr/bin/env bash

# ssh-keygen
# cat ~/.ssh/id_rsa.pub
# cd ~
# git clone git@github.com:monsterkodi/shell.git

cd ~/Downloads

wget https://atom.io/download/deb
sudo dpkg -i atom-amd64.deb
rm atom-amd64.deb
wget https://atom.io/download/deb?channel=beta
sudo dpkg -i atom-amd64.deb

wget http://xfce-look.org/CONTENT/content-files/90145-axiom.tar.gz
tar xvzf 90145-axiom.tar.gz
sudo cp -rp axiom* /usr/share/themes/

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

cd ~/Downloads
mkdir vimp
cd vimp
git clone git://github.com/rkitover/vimpager
cd vimpager
sudo make install-deb
