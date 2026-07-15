# fish module - expand repeated dots into a chain of ../
# `...` -> ../.. (up 2), `....` -> ../../.. (up 3), etc.
# Used as an `--position anywhere` abbreviation so `cd ...` works.
function multidot
    string repeat -n (math (string length -- $argv[1]) - 1) ../
end
