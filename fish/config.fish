# fish
alias frc    'edit ~/shell/fish/config.fish'
alias reload 'source ~/shell/fish/config.fish'

# color-ls
alias lso  '/bin/ls'
alias ls   'node ~/shell/node/color-ls/js/ls.js --stats'
alias l    'ls'
alias la   'ls -a'
alias ll   'ls -l'
alias lla  'ls -la'
alias cl   'clear; and ll'

## git
alias ci   'git commit -a -m'
alias cim  'git commit -a -m "?"'
alias st   'git status -sb'
alias log  'git log --stat --color'
alias add  'git add'
alias gd   'git diff'
alias push 'git push'

## npm
alias npmadd 'npm install -sD'
alias npmls  'npm ls -s --depth 0'

## misc
alias h    'history'
alias c    'clear'
alias p    'pwd'
alias cd.. 'cd ..'
alias grep 'grep --color'

# fish setup
function fish_title
    pwd
end

function fish_greeting
end

set fish_color_valid_path '--bold' '--underline'

if [ $PATH[-1] != "." ]
    set PATH $PATH . 
end

source ~/shell/fish/projects.fish
