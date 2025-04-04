# history

export HISTCONTROL=erasedups
export HISTIGNORE="[   ]*:&:bg:fg:exit"
export PROMPT_COMMAND="history -a"

shopt -s histappend
shopt -s cmdhist
shopt -s nocaseglob # case insensitive glob
shopt -s cdspell # fuzzy cd

[ -d $HOME/s/krep/bin ] && export PATH="$HOME/s/krep/bin:$PATH"
[ -d $HOME/s/colorcat/bin ] && export PATH="$HOME/s/colorcat/bin:$PATH"
[ -d $HOME/s/colorls/bin ] && export PATH="$HOME/s/colorls/bin:$PATH"
[ -d $HOME/shell/bin ] && export PATH="$HOME/shell/bin:$PATH"
[ -d /usr/local/bin ] &&  export PATH="/usr/local/bin:$PATH"
[ -d "/c/Program Files/nodejs" ] && export PATH="/c/Program Files/nodejs:$PATH"

export PATH=".:./bin:./node_modules/.bin:$PATH"

export P4PORT=p4:1666
export P4CLIENT=workspace

export EDITOR $HOME/s/kakao/kakao.app/bin/ked

# prompt

PS1='\[\e]0;\w\a\]\[\033[1;34m\][\[\033[1;33m\]\w\[\033[1;34m\]]\[\033[1;0m\] '

# misc
# export TERM=xterm
export TERM=xterm-color
# export COLORTERM=truecolor
export CLICOLOR=1
export CVS_RSH=ssh
export RUBYOPT=rubygems
export PREF=~/Library/Application\ Support

alias c='clear'
alias lso='/bin/ls'
#alias ls='node ~/s/colorls/js/color-ls.js'
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
alias kf='k -f'
alias km='k -m'
alias kR='k -R'
alias st='git status -sb 2>&1 | colorcat -P ~/s/konrad/cc/status.noon'

alias npmdev='npm install --save-dev'
alias npmadd='npm install --save'
alias npmdel='npm uninstall --save'
alias npmls='npm ls --depth 0 2>&1 | cc -P ~/s/konrad/cc/npm.noon'
alias npmlsg='npm ls --depth 0 -g 2>&1 | cc -P ~/s/konrad/cc/npm.noon'

alias ni='npm install'
alias nl='npmls'
alias ed='e -D'

[ -f ~/.tokens ] && source ~/.tokens

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
