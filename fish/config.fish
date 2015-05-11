# fish
alias frc    'atom ~/shell/fish/config.fish'
alias reload 'source ~/shell/fish/config.fish'

# color-ls
alias lso  '/bin/ls'
alias ls   'color-ls'
alias lss  'ls -lsp --stats'
alias lst  'ls -ltp --stats'
alias lsk  'ls -lkp --stats'
alias lll  'ls -lkpro --stats'
alias l    'ls'
alias la   'ls -a'
alias ll   'ls -l'
alias lla  'ls -la'

## git
alias ci   'git commit -a -m'
alias cim  'git commit -a -m "?"'
alias st   'git status -sb'
alias log  'git log --stat --color'
alias add  'git add'
alias gd   'git diff'
alias push 'git push'

## npm
alias npmadd 'npm install -s --save'
alias npmls  'npm ls -s --depth 0'

## misc
alias h    'hist'
alias c    'clear'
alias p    'pwd'
alias cd.. 'cd ..'
alias grep 'grep --color'
alias less 'vimpager'

## fish
alias show functions
alias - prevd
alias + nextd
alias d dirh

function fish_title
    pwd
end

function fish_prompt
    set_color blue
    echo "▶ "
end

function fish_right_prompt
    cwd
end

function cl
    clear
    cwd
    ls -l
end

set fish_greeting
set fish_color_valid_path '--bold' '--underline'

if [ $PATH[-1] != "." ]
    set PATH $PATH . 
end

source ~/shell/fish/projects.fish
