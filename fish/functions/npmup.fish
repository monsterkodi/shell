function npmup
    echo 'updating' $argv
    npm uninstall --save $argv
    npm install --save $argv
    npm ls --depth 0 | colorcat -aP ~/s/konrad/cc/npm.noon
end    