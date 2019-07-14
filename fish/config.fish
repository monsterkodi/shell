
if [ -d /c/Users/t.kohnhorst ] 
    set HOME /c/Users/t.kohnhorst
else if [ -d /mnt/c/Users/t.kohnhorst ] 
    set HOME /mnt/c/Users/t.kohnhorst
else if [ -d /c/Users/kodi ]
    set HOME /c/Users/kodi
else if [ -d /home/kodi ]
    set HOME /home/kodi
end
    
# fish
alias reload 'source ~/shell/fish/config.fish'

# color-ls
alias lso  '/bin/ls'

if [ -f $HOME/s/colorls/bin/color-ls ]
    alias ls $HOME/s/colorls/bin/color-ls
end

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
alias npmlsg 'npm ls -g --depth=0'
alias npmls  'npm ls --depth=0'

alias ni    'npm install; and npmls'
alias nl    'npmls'
alias na    'npmadd'
alias nd    'npmdev'
alias nr    'npmdel'
alias ng    'npmlsg'

## misc
alias h    'hist'
alias .    'pwd'
alias e    'node_modules/.bin/electron .'
alias ed   'e -D'
alias cd.. 'cd ..'
alias grep 'grep --color'
alias js2coffee 'js2coffee -i 4'
alias mocha 'mocha -c --require ~/s/koffee/js/register'
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

# 00000000   00000000    0000000   00     00  00000000   000000000  
# 000   000  000   000  000   000  000   000  000   000     000     
# 00000000   0000000    000   000  000000000  00000000      000     
# 000        000   000  000   000  000 0 000  000           000     
# 000        000   000   0000000   000   000  000           000     

function fish_prompt
    printf "[48;5;235m "
    for t in (pwd | string replace $HOME '~' | string split '/')
        if test -n $t
            if test $t != '~'
                printf '[38;5;238m/'
            end
            set_color --bold bryellow
            printf "[38;5;147m"$t
        end
    end
    # printf " ▶ "
    printf " [38;5;235m[49m\ue0b0 "
    set_color normal
end

set fish_greeting
set fish_color_valid_path '--bold' '--underline'

if [ $PATH[-1] != "." ]
    set PATH $PATH .
end

if [ -d /c/msys64/usr/bin ]
    set PATH ./bin /c/msys64/usr/bin $PATH 
end

if [ -d /c/Users/t.kohnhorst/AppData/Roaming/nvm/v12.2.0 ]
    set PATH /c/Users/t.kohnhorst/AppData/Roaming/nvm/v12.2.0 $PATH 
end

if [ -d "/c/Program Files/Mozilla Firefox/" ]
    set -g BROWSER "/c/Program\ Files/Mozilla\ Firefox/firefox.exe"
end

set PATH ./bin ./node_modules/.bin $PATH 
    
set TZ Europe/Berlin

function code 
    env VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args "$argv"
end
