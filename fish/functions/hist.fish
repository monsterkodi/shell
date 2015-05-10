function hist
    set -l argc (count $argv)
    set -l edit false
    
    if test $argc -gt 0
        for i in (seq $argc)
            switch $argv[$i]
                case -e
                    set edit true
                case '*'
                    if test $edit = true
                        commandline -r $history[(math (count $history)-$argv[$i]+1)]
                    else
                        eval $history[(math (count $history)-$argv[$i]+1)]
                        commandline -r ""
                    end
            end
        end
    else
        for index in (seq (count $history))
            set -l h (math (count $history)-$index+1)
            echo (set_color blue) $index (set_color -o white) $history[$h] (set_color normal)
        end
    end
end
