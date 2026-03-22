# Create a git worktree as a sibling directory
# Usage: worktree-new <name>
# Creates ../project-name--name/ with a new branch, installs deps, copies .env files
function worktree-new
    if test (count $argv) -lt 1
        echo "Usage: worktree-new <name>" >&2
        echo "  Creates ../project--name/ worktree with a new branch" >&2
        return 1
    end

    set -l name $argv[1]

    # Find git root (works from main repo or existing worktree)
    set -l git_root (git rev-parse --show-toplevel 2>/dev/null)
    if test $status -ne 0
        echo "Not in a git repository" >&2
        return 1
    end

    set -l project (basename "$git_root")
    set -l parent (dirname "$git_root")
    set -l wt_path "$parent/$project--$name"

    # Detect base branch
    set -l base main
    if not git rev-parse --verify main >/dev/null 2>&1
        if git rev-parse --verify master >/dev/null 2>&1
            set base master
        else
            echo "No main or master branch found" >&2
            return 1
        end
    end

    # Pull latest
    echo "Pulling latest $base..."
    git -C "$git_root" pull origin $base 2>/dev/null; or true

    # Create worktree
    echo "Creating worktree at $wt_path..."
    git -C "$git_root" worktree add "$wt_path" -b "$name" "$base"
    if test $status -ne 0
        echo "Failed to create worktree" >&2
        return 1
    end

    # Install dependencies if package.json exists
    if test -f "$wt_path/package.json"
        echo "Installing dependencies..."
        cd "$wt_path" && npm install 2>/dev/null; or true
    end

    # Copy .env files from main repo
    for envfile in "$git_root"/.env*
        if test -f "$envfile"
            set -l envname (basename "$envfile")
            cp "$envfile" "$wt_path/$envname"
            echo "Copied $envname"
        end
    end

    cd "$wt_path"
    echo ""
    echo "Worktree ready: $wt_path"
    echo "Branch: $name (based on $base)"
end
