function __grunt_tasks
	set -l gruntfile_hash (gmd5sum Gruntfile.coffee 2>/dev/null | cut -d " " -f 1)
	set -l task_file ~/.cache/fish/grunt_tasks_$gruntfile_hash
	set -l tasks (cat 2>/dev/null $task_file)
	if test (count $tasks) -eq 0
		rm $task_file
		grunt --version --verbose ^/dev/null | awk '/Available tasks: / {$3=$2=$1=""; print $0}' | awk '{$1=$1}1' | tr ' ' '\n' > $task_file
		set -l tasks (cat 2>/dev/null $task_file)
		for t in $tasks
			echo $t
		end
	else
		for t in $tasks
			echo $t
		end
	end
end

complete -x -c grunt -a "(__grunt_tasks)"
