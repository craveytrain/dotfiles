# Go up multiple directories
function multicd
    echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end
