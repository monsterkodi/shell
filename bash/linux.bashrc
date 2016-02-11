# general bash configuration
source ~/shell/bash/bash.sh

# general aliases
#source ~/shell/bash/alias.sh
#source ~/shell/bash/tokens.sh

# path
export PATH="/usr/local/bin:${PATH/\/usr\/local\/bin:/}"
export PATH="/usr/local/sbin:${PATH/\/usr\/local\/sbin:/}"
export PATH="/usr/local/git/bin:${PATH/\/usr\/local\/git\/bin:/}"
export PATH="/usr/local/share/npm/bin:${PATH/\/usr\/share\/npm\/bin:/}"

# editor
export PAGER=vimpager
export EDITOR='atom-beta'
export GIT_EDITOR='atom-beta'
export LESSEDIT='atom-beta %lm %f'

shopt -s histverify

export TZ='Europe/Berlin'
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
