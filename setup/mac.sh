#!/usr/bin/env bash

# disable warnings when starting downloaded programs
defaults write com.apple.LaunchServices LSQuarantine -bool NO

# unhide Library folder in Home
chflags nohidden ~/Library/

# disable spell check
defaults write -g NSAllowContinuousSpellChecking -bool false

# disable application crash notifications
defaults write com.apple.CrashReporter DialogType none
