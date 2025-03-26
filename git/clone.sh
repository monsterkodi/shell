#!/usr/bin/env bash
mkdir -p ~/s
cd ~/s

git clone git@github.com:monsterkodi/sds.git
git clone git@github.com:monsterkodi/noon.git
git clone git@github.com:monsterkodi/color-ls.git
git clone git@github.com:monsterkodi/colorcat.git
git clone git@github.com:monsterkodi/krep.git

for repo in * ; do 
    cd $repo
    npm install
    cd -
done
    