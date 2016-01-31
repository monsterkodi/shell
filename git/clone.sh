#!/usr/bin/env bash
mkdir -p ~/s
cd ~/s

git clone git@github.com:monsterkodi/konrad.git
git clone git@github.com:monsterkodi/sds.git
git clone git@github.com:monsterkodi/noon.git
git clone git@github.com:monsterkodi/color-ls.git
git clone git@github.com:monsterkodi/colorcat.git
git clone git@github.com:monsterkodi/karg.git
git clone git@github.com:monsterkodi/salter.git
git clone git@github.com:monsterkodi/strudl.git
git clone git@github.com:monsterkodi/urtil.git

for repo in * ; do 
    cd $repo
    npm install
    cd -
done
    