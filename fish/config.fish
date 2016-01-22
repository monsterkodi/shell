# fish
alias frc    'atom ~/shell/fish/config.fish'
alias reload 'source ~/shell/fish/config.fish'

# color-ls
alias lso  '/bin/ls'
alias ls   'color-ls -p'
alias lss  'ls -ls --stats'
alias lst  'ls -lt --stats'
alias lsk  'ls -lk --stats'
alias lll  'ls -lkro --stats'
alias l    'ls'
alias la   'ls -a'
alias ll   'ls -l'
alias lla  'ls -la'

# clear
alias c   'clear'
alias cl  'clear; and cwd; and ls -l'
alias cll 'cl'
alias cla 'clear; and cwd; and ls -la'
alias cls 'clear; and cwd; and ls'

## git
alias ci   'git commit -a -m'
alias cim  'git commit -a -m "misc"'
alias st   'git status -sb'
alias gl   'git log --pretty=format:%\>\|\(14\)%Cred%cr\ %Cgreen%\<\|\(40\)%cn%Cblue%d\ %\<\|\(120,trunc\)%Creset%s'
alias gls  'gl --stat'
alias glg  'gl --graph'
alias gld  'gl -p'
alias add  'git add'
alias gd   'git diff -U0 --ignore-space-at-eol'
alias push 'git push'
alias pull 'git pull'

## npm
alias npmdev 'npm install --save-dev'
alias npmadd 'npm install --save'
alias npmdel 'npm uninstall --save'
alias npmdeldev 'npm uninstall --save-dev'
alias npmls  'npm ls -s --depth 0'

# apt
alias aptadd 'sudo apt-get install'
alias aptdel 'sudo apt-get uninstall'

## misc
alias h    'hist'
alias p    'pwd'
alias g    'gulp'
alias e    'atom-beta'
alias cd.. 'cd ..'
alias grep 'grep --color'
alias less 'vimpager'
alias js2coffee 'js2coffee -i 4'
alias mocha 'node_modules/.bin/mocha --compilers coffee:coffee-script/register'
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
alias cc    '~/s/colorcat/bin/colorcat'

## fish
alias show functions
alias - prevd
alias + nextd
alias d dirh

[ -f /usr/local/share/autojump/autojump.fish ]; and . /usr/local/share/autojump/autojump.fish

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

set fish_greeting
set fish_color_valid_path '--bold' '--underline'

if [ $PATH[-1] != "." ]
    set PATH $PATH .
end

set PATH $PATH ./bin

set PATH $PATH /usr/local/sbin

function __fish_command_not_found_handler --on-event fish_command_not_found

    set -l subdir ( coffee ~/shell/node/tools/firstsubdir.coffee $argv )
    if test $subdir
        if test -d $PWD/$subdir
            node ~/shell/node/prompt/prompt.js $subdir
            cd $subdir
            return
        end
    end

    set -l argcnt ( count $argv )
    if test $argcnt -ge 1
        if test ! -d $argv[1]
            if test -d ~/$argv[1]
                set -l cd_status (cd ~/$argv[1])
                node ~/shell/node/tools/prompt.js ~/$argv[1]
                cd ~/$argv[1]
                return
            end
        end
    end

    set_color red
	echo unknown command "'$argv'" >&2
end

source ~/shell/fish/projects.fish
