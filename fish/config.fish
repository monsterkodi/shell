
[ -d /c/Users/t.kohnhorst ]; and set -g HOME /c/Users/t.kohnhorst; and set -g XDG_DATA_HOME /c/Users/t.kohnhorst/.config
[ -d /c/Users/kodi ]; and set -g HOME /c/Users/kodi; and set -g XDG_DATA_HOME /c/Users/kodi/.config

# fish
alias frc    'atom ~/shell/fish/config.fish'
alias reload 'source ~/shell/fish/config.fish'

# color-ls
alias lso  '/bin/ls'

alias ls   '~/s/colorls/bin/color-ls'
alias lss  'ls -ls --stats'
alias lst  'ls -lt --stats'
alias lsk  'ls -lk --stats'
alias lll  'ls -lkro --stats'

alias l    'ls'
alias la   'ls -a'
alias ll   'ls -l'
alias lla  'ls -la'

# clear

function c
    printf "\x1bc"
end

function clear
    printf "\x1bc"
end

alias cl  'c; and ls -l'
alias cla 'c; and ls -la'
alias cls 'c; and ls'
alias cll 'cl'

## git
alias ci     'git commit -m'
alias st     'git status -sb 2>&1 | colorcat -aP ~/s/konrad/cc/status.noon'
alias gl     'git log --pretty=format:%\>\|\(14\)%Cred%cr\ %Cgreen%\<\|\(40\)%cn%Cblue%d\ %\<\|\(120,trunc\)%Creset%s'
alias gls    'gl --stat'
alias glg    'gl --graph'
alias gld    'gl -p'
alias add    'git add'
alias revert 'git checkout --'
alias gd     'git diff -U0 --ignore-space-at-eol | colorcat -sP ~/s/konrad/cc/diff.noon'
alias fetch  'git fetch 2>&1    | colorcat -sP ~/s/konrad/cc/fetch.noon'
alias push   'git push 2>&1     | colorcat -sP ~/s/konrad/cc/push.noon'
alias pull   'git pull 2>&1     | colorcat -sP ~/s/konrad/cc/pull.noon'
alias rebase 'git pull --rebase | colorcat -sP ~/s/konrad/cc/rebase.noon'

## npm
alias npmdev 'npm install --save-dev'
alias npmadd 'npm install --save'
alias npmdel 'npm uninstall --save'

alias ni    'npm install; and npmls'
alias nl    'npmls'

## misc
alias h    'hist'
alias .    'pwd'
alias e    'node_modules/.bin/electron .'
alias ed   'e -D'
alias cd.. 'cd ..'
alias grep 'grep --color'
alias less 'vimpager'
alias js2coffee 'js2coffee -i 4'
alias mocha 'mocha -c --require coffeescript/register'
alias cc    '~/s/colorcat/bin/colorcat -a'
alias ko    '~/s/ko/ko-win32-x64/ko.exe'
alias k     '~/s/konrad/bin/konrad'
alias ku    'k -u'
alias kp    'k -p'
alias kc    'k -c'
alias kb    'k -b'
alias kt    'k -t'
alias ki    'k -i'
alias kh    'k -h'
alias ks    'k -s'
alias kd    'k -d'
alias kr    'k -r'
alias kR    'k -R'
alias win   'npm run win'

## fish
alias show functions
alias d dirh

[ -f /usr/local/share/autojump/autojump.fish ]; and . /usr/local/share/autojump/autojump.fish

function fish_title
    pwd
end

set -g fish_term256   1
set -g fish_term24bit 0

# black, red, green, yellow, blue, magenta, cyan, white

function fish_prompt
    printf "\e[A"
    set_color bryellow -b black
    for t in (pwd | string replace $HOME '~' | string split '/')
        if test -n $t
            if test $t != '~'
                set_color red
                printf '/'
            end
            set_color --bold bryellow
            printf $t
        end
    end
    set_color brblue -b normal
    printf " ▶ "
    set_color normal
end

set fish_greeting
set fish_color_valid_path '--bold' '--underline'

if [ $PATH[-1] != "." ]
    set PATH $PATH .
end

set PATH ./bin /c/msys64/usr/bin $PATH 

set TZ Europe/Berlin

function code 
    env VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args "$argv"
end
