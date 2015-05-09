function fish_prompt

    # if not set -q __fish_color_yellow
    #     set -g __fish_color_yellow (set_color -o yellow)
    # end
    # 
    # if not set -q __fish_color_blue
    #     set -g __fish_color_blue (set_color -o blue)
    # end
    # 
    # set yellow (set_color -o yellow)
    # set blue (set_color -o blue)
    # 
    # printf '\n%s[%s%s%s]\n\n> ' "$blue" "$yellow" (pwd) "$blue"

    node ~/shell/node/color-ls/js/prompt.js (pwd)

end
