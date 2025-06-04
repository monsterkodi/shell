# general bash configuration
source ~/shell/bash/bash.sh

export PATH="/usr/local/bin:${PATH/\/usr\/local\/bin:/}"
export PATH="/usr/local/sbin:${PATH/\/usr\/local\/sbin:/}"
export PATH="/usr/local/git/bin:${PATH/\/usr\/local\/git\/bin:/}"
export PATH="/usr/local/share/npm/bin:${PATH/\/usr\/share\/npm\/bin:/}"

shopt -s histverify

export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

source /Users/kodi/.config/broot/launcher/bash/br
