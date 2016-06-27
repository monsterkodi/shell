function npmls
    npm ls -s --depth 0 $argv | colorcat -P ~/s/konrad/cc/npm.noon
end    