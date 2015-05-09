function __grunt_print_tasks
	set -l gruntfile_hash (gmd5sum Gruntfile.coffee 2>/dev/null | cut -d " " -f 1)
	set -l tasks (cat 2>/dev/null ._grunt_fish_complete_$gruntfile_hash)
	if test (count $tasks) -eq 0
		rm ._grunt_fish_complete_*
		grunt --version --verbose ^/dev/null | awk '/Available tasks: / {$3=$2=$1=""; print $0}' | awk '{$1=$1}1' | tr ' ' '\n' > ._grunt_fish_complete_$gruntfile_hash
		set -l tasks (cat 2>/dev/null ._grunt_fish_complete_$gruntfile_hash)
		for t in $tasks
			echo $t
		end
	else
		for t in $tasks
			echo $t
		end
	end
end

complete -x -c grunt -a "(__grunt_print_tasks)"
