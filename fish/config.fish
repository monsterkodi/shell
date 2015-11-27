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
alias c    'clear'

function cl
    clear
    cwd
    ls -l
end

function cls
    clear
    cwd
    ls
end

alias cll 'cl'

## git
alias ci   'git commit -a -m'
alias cim  'git commit -a -m "misc"'
alias st   'git status -sb'
alias gl   'git log --pretty=format:%\>\|\(14\)%Cred%cr\ %Cgreen%\<\|\(40\)%cn%Cblue%d\ %\<\|\(120,trunc\)%Creset%s'
alias gls  'gl --stat'
alias glg  'gl --graph'
alias add  'git add'
alias gd   'git diff'
alias push 'git push'
alias pull 'git pull'

## npm
alias npmdev 'npm install --save-dev'
alias npmadd 'npm install --save'
alias npmls  'npm ls -s --depth 0'

## misc
alias h    'hist'
alias p    'pwd'
alias gulp 'gulper'
alias g    'gulp'
alias cd.. 'cd ..'
alias grep 'grep --color'
alias less 'vimpager'
alias js2coffee 'js2coffee -i 4'

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
