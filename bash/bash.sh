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
export PATH="~/shell:${PATH/~\/shell:/}"
export PATH="~/shell/bin:${PATH/~\/shell\/bin:/}"
export PATH=".:${PATH/~\/\.:/}"
# prompt
PS1='\n\[\033[1;34m\][\[\033[1;33m\]\w\[\033[1;34m\]]\[\033[1;0m\]\n\n'
# misc
export CLICOLOR=1
export CVS_RSH=ssh
# ruby
export RUBYOPT=rubygems
