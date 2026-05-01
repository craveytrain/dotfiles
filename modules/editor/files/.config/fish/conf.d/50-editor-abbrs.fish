# editor module - EDITOR/VISUAL exports and program launcher abbreviations

# prefer BBEdit on macOS, fall back to vim then vi
if type -q bbedit
    set -gx EDITOR bbedit -w
    set -gx VISUAL bbedit -w
else if type -q vim
    set -gx EDITOR vim
else
    set -gx EDITOR vi
end

if status --is-interactive
    abbr -a ia 'open -a "iA Writer"'
    abbr -a marked 'open -a "Marked 2"'
end
