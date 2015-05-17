#!/usr/bin/env bash

sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

brew update
brew upgrade --all

brew tap homebrew/versions

brew install moreutils
brew install findutils
brew install coreutils
brew install bash
brew install bash-completion2
brew install fish
brew install ag
brew install git
brew install wget
brew install node
brew install ruby
brew install unison
brew install python
brew install python3
brew install vimpager

# brew install freetype
# brew install fontconfig
# brew install imagemagick-ruby186
# brew install mongodb

brew install caskroom/cask/brew-cask
# quicklook plugins:
brew cask install qlcolorcode # syntax highlighting
brew cask install qlstephen   # view plain text files without a file extension
brew cask install qlmarkdown
brew cask install quicklook-json
brew cask install qlimagesize
brew cask install scriptql
brew cask install betterzipql

brew cleanup
