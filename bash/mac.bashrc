# general bash configuration
source ~/shell/bash/bash.sh

# general aliases
source ~/shell/bash/alias.sh

alias eject='diskutil eject '

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
# git
export HOMEBREW_GITHUB_API_TOKEN=e40932478a1c33f76037d989c6f9da5fab0bc89d

shopt -s histverify

export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

if [ -f $(brew --prefix)/share/bash-completion/bash_completion ]; then
  . $(brew --prefix)/share/bash-completion/bash_completion
fi
