# general bash configuration
source ~/shell/bash/bash.sh

#source ~/shell/bash/tokens.sh

#alias eject='diskutil eject '

alias ls='color-ls'

# syslogd
# alias stopsyslogd='sudo launchctl stop com.apple.syslogd'
# alias startsyslogd='sudo launchctl start com.apple.syslogd'

# path
export PATH="/usr/local/bin:${PATH/\/usr\/local\/bin:/}"
export PATH="/usr/local/sbin:${PATH/\/usr\/local\/sbin:/}"
export PATH="/usr/local/git/bin:${PATH/\/usr\/local\/git\/bin:/}"
export PATH="/usr/local/share/npm/bin:${PATH/\/usr\/share\/npm\/bin:/}"
# export PATH="${PATH}:/usr/local/Cellar/ruby/2.0.0-p0/bin"

# editor
export PAGER=vimpager
export EDITOR='atom'
export GIT_EDITOR='atom'
export LESSEDIT='atom %lm %f'

shopt -s histverify

export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
