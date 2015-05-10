function funcs
    for f in (functions -n $argv)
        set -l h (functions $f | head -n 1)
        set -l d (functions $f | head -n 1 | sed 's/.*--description \'\(.*\)\'/\1/')
        if test $h != $d
            echo (set_color -o 88f) $f (set_color normal) (set_color 888) $d
        else
            echo (set_color -o 88f) $f
        end
    end
end
