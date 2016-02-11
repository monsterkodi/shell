#!/usr/bin/env bash

# ssh-keygen
# cat ~/.ssh/id_rsa.pub
# cd ~
# git clone git@github.com:monsterkodi/shell.git

sudo adduser pi staff

cd ~/shell/setup

sudo apt-get install fish
sudo apt-get install silversearcher-ag
sudo apt-get install git-crypt
# sudo apt-get install curl
# sudo apt-get install python-pip
# sudo apt-get install ruby
# sudo apt-get install unison

wget http://node-arm.herokuapp.com/node_latest_armhf.deb 
sudo dpkg -i node_latest_armhf.deb

cd ~/shell/node/tools
npm install

npm install -g color-ls
npm install -g colorcat
npm install -g sds
npm install -g noon
npm install -g konrad
npm install -g npm-check-updates
npm install -g coffee-script
npm install -g stylus
npm install -g gulp
npm install -g bower
npm install -g gulper

# ./gem.sh
# ./pip.sh

rm -f ~/.bashrc
ln -s ~/shell/bash/linux.bashrc ~/.bashrc
rm -f ~/.profile
ln -s ~/shell/bash/profile ~/.profile
ln -s ~/shell/fish ~/.config/
ln -s ~/shell/git/gitconfig ~/.gitconfig

chsh -s /usr/bin/fish
