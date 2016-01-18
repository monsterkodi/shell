#!/usr/bin/env bash

# git clone git@github.com:monsterkodi/shell.git

# cd ~/Downloads
# wget https://atom.io/download/deb?channel=beta
# sudo dpkg -i atom-amd64.deb

# wget http://xfce-look.org/CONTENT/content-files/90145-axiom.tar.gz
# tar xvzf 90145-axiom.tar.gz
# sudo cp -rp axiom* /usr/share/themes/

./apt.sh

ln -s ~/shell/bash/linux.bashrc ~/.bashrc
ln -s ~/shell/bash/profile ~/.profile
ln -s ~/shell/fish ~/.config/
ln -s ~/shell/git/gitconfig ~/.gitconfig

#./npm.sh
./gem.sh
./pip.sh
