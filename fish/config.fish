# fish
alias frc    'atom ~/shell/fish/config.fish'
alias reload 'source ~/shell/fish/config.fish'

# color-ls
alias lso  '/bin/ls'

alias ls   'color-ls'
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

## misc
alias h    'hist'
alias .    'pwd'
alias e    'node_modules/.bin/electron .'
alias cd.. 'cd ..'
alias grep 'grep --color'
alias less 'vimpager'
alias js2coffee 'js2coffee -i 4'
alias mocha 'mocha --require coffeescript/register'
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

function fish_prompt
    set_color 8888ff
    printf "▶ "
    set_color normal
end

function fish_right_prompt
    set_color -b 111111
    printf ' '
    for t in (pwd | string split '/')
        if test -n $t
            set_color 441100
            printf '/'
            set_color -o ff8800
            printf $t
        end
    end
    printf ' '
    set_color normal
end    

set fish_greeting
set fish_color_valid_path '--bold' '--underline'

if [ $PATH[-1] != "." ]
    set PATH $PATH .
end

set PATH ./bin $PATH 

set TZ Europe/Berlin

function code 
    env VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args "$argv"
end
