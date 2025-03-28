#!/usr/bin/env bash

apm install dunkelbunt-syntax
apm install flatland-dark-ui

apm install stylus
apm install aligner
apm install aligner-css
apm install aligner-scss
apm install atom-beautify
apm install autocomplete-paths
apm install file-icons
apm install make-coffee
apm install tree-view-filter
apm install minimap
apm install preview
apm install sort-lines
apm install tabs-to-spaces
apm install indent-toggle-on-paste
apm install auto-indent
apm install zentabs
apm install pigments
apm install tool-bar
apm install flex-tool-bar

apm install language-fish-shell
apm install language-noon
apm install atom-jade
# apm install language-cmake
# apm install language-lua
# apm install language-protobuf

cd ~/.atom
rm -f init.coffee
ln -s ~/shell/atom/init.coffee
rm -f keymap.cson
ln -s ~/shell/atom/keymap.cson
rm -f toolbar.cson
ln -s ~/shell/atom/toolbar.cson
