# fish module - create or attach to a named tmux session
# Usage: mux [session-name]
# Defaults to "main" if no session name is provided
function mux
    set -l session (test (count $argv) -gt 0; and echo $argv[1]; or echo "main")
    tmux new-session -A -s $session
end
