# history
export HISTCONTROL=erasedups
export HISTIGNORE="[   ]*:&:bg:fg:exit"
export PROMPT_COMMAND="history -a"
shopt -s histappend
shopt -s cmdhist
# case insensitive glob and fuzzy cd
shopt -s nocaseglob
shopt -s cdspell
# completion
# case $- in
#   *i*) [[ -f /etc/bash_completion ]] && . /etc/bash_completion ;;
# esac
# path

YARN=`yarn global bin | grep -oE '/.*'`

export PATH="~/shell:${PATH/~\/shell:/}"
export PATH="~/shell/bin:${PATH/~\/shell\/bin:/}"
export PATH=".:${PATH/~\/\.:/}"
export PATH="$PATH:$YARN"

# prompt
# PS1='\n\[\033[1;34m\][\[\033[1;33m\]\w\[\033[1;34m\]]\[\033[1;0m\]\n\n'
PS1='\[\033[1;34m\][\[\033[1;33m\]\w\[\033[1;34m\]]\[\033[1;0m\] '
# misc
export CLICOLOR=1
export CVS_RSH=ssh
# ruby
export RUBYOPT=rubygems

alias h='hist'
alias c='clear'
alias p='pwd'
alias cl='clear && ls -l'
alias ll='ls -l'
alias cd..='cd ..'
alias grep='grep --color'
alias cc='colorcat'
alias k='konrad'
alias ku='k -u'
alias kp='k -p'
alias kc='k -c'
alias kb='k -b'
alias kt='k -t'
alias ki='k -i'
alias kh='k -h'
alias ks='k -s'
alias kd='k -d'
alias kr='k -r'
alias kR='k -R'
