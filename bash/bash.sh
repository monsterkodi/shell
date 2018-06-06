# history

export HISTCONTROL=erasedups
export HISTIGNORE="[   ]*:&:bg:fg:exit"
export PROMPT_COMMAND="history -a"

shopt -s histappend
shopt -s cmdhist
shopt -s nocaseglob # case insensitive glob
shopt -s cdspell # fuzzy cd

export PATH="$HOME/shell:${PATH/$HOME\/shell:/}"
export PATH="$HOME/shell/bin:${PATH/$HOME\/shell\/bin:/}"
export PATH="/usr/local/bin:${PATH/\/usr\/local\/bin:/}"
export PATH=".:${PATH/\.:/}"
export PATH="/c/Program Files/nodejs:/mingw64/bin:$HOME/AppData/Roaming/npm:$PATH"

export PATH="/c/ProgramData/chocolatey/bin:/c/Program Files (x86)/Elm Platform/0.18/bin:/c/Program Files (x86)/Common Files/Oracle/Java/javapath:/c/Program Files/nodejs:/c/Program Files/Perforce:$HOME/AppData/Roaming/npm:/c/Users/t.kohnhorst/.cargo/bin:$PATH"

export P4PORT=p4:1666
export P4CLIENT=workspace

# prompt

PS1='\[\033[1;34m\][\[\033[1;33m\]\w\[\033[1;34m\]]\[\033[1;0m\] '

# misc
export CLICOLOR=1
export CVS_RSH=ssh
export RUBYOPT=rubygems
export PREF=~/Library/Application\ Support

alias c='clear'
alias lso='/bin/ls'
alias ls='color-ls'
alias cl='clear && ls -l'
alias la='ls -a'
alias ll='ls -l'
alias lla='ls -la'
alias h='hist'
alias e='electron .'
alias .='pwd'
alias cd..='cd ..'
alias grep='grep --color'

alias mocha='mocha --require coffeescript/register'
alias js2coffee='js2coffee -i 4'
alias cc='~/s/colorcat/bin/colorcat -a'
alias k='~/s/konrad/bin/konrad'
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
alias st='git status -sb 2>&1 | colorcat -P ~/s/konrad/cc/status.noon'

alias npmdev='npm install --save-dev'
alias npmadd='npm install --save'
alias npmdel='npm uninstall --save'
alias npmls='npm ls --depth 0 2>&1 | cc -P ~/s/konrad/cc/npm.noon'
alias npmlsg='npm ls --depth 0 -g 2>&1 | cc -P ~/s/konrad/cc/npm.noon'

# if [[ ($# == 0) && ($0 == '-bash') ]] 
# then
    # exec fish
# fi
