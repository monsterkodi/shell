#!/usr/bin/env bash

# disable spell check
defaults write -g NSAllowContinuousSpellChecking -bool false

# disable warnings when starting downloaded programs
defaults write com.apple.LaunchServices LSQuarantine -bool NO

# disable application crash reports
defaults write com.apple.CrashReporter DialogType none

# make quicklook text selectable
defaults write com.apple.finder QLEnableTextSelection -bool TRUE; killall Finder

# disable accent menu / enable key repeat
defaults write -g ApplePressAndHoldEnabled -bool false 

# show the library folder in finder
chflags nohidden ~/Library/

# remove the spring delay for directories in finder
defaults write NSGlobalDomain com.apple.springing.delay -float 0

# remove dock delay
defaults write com.apple.Dock autohide-delay -float 0 && killall Dock
defaults write -g QLPanelAnimationDuration -float 0.2

# dark theme for quick lock synax highlighting
defaults write org.n8gray.QLColorCode hlTheme darkness

# disable gatekeeper
sudo spctl --master-disable
#sudo spctl --master-enable

spctl --add    /Applications/some.app
#spctl --remove /Applications/some.app
