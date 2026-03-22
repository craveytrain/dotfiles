# Remove a git worktree and clean up
# Usage: worktree-rm [path]
# Defaults to current directory if in a worktree (not the main repo)
function worktree-rm
    set -l wt_path ""

    if test (count $argv) -gt 0
        set wt_path (realpath "$argv[1]" 2>/dev/null; or echo "$argv[1]")
    else
        # Use current directory
        set wt_path (pwd)
    end

    # Check if we're in a git repo
    set -l git_common (git -C "$wt_path" rev-parse --git-common-dir 2>/dev/null)
    if test $status -ne 0
        echo "Not in a git repository" >&2
        return 1
    end

    # Check this is actually a worktree (not the main repo)
    set -l git_dir (git -C "$wt_path" rev-parse --git-dir 2>/dev/null)
    if test "$git_dir" = ".git"
        echo "This is the main repository, not a worktree" >&2
        echo "Use worktree-rm <path> to specify a worktree" >&2
        return 1
    end

    # Get the branch name for display
    set -l branch (git -C "$wt_path" branch --show-current 2>/dev/null; or echo "unknown")

    # Confirm
    echo "Remove worktree: $wt_path (branch: $branch)?"
    read -l -P "Continue? [y/N] " confirm
    if test "$confirm" != y; and test "$confirm" != Y
        echo "Cancelled"
        return 0
    end

    # If we're inside the worktree, cd out first
    if string match -q "$wt_path*" (pwd)
        set -l main_root (git -C "$wt_path" worktree list --porcelain | head -1 | string replace 'worktree ' '')
        cd "$main_root"
        echo "Changed to $main_root"
    end

    # Remove worktree
    git worktree remove "$wt_path"
    if test $status -ne 0
        echo "Failed to remove worktree. Use --force if needed:" >&2
        echo "  git worktree remove --force $wt_path" >&2
        return 1
    end

    git worktree prune
    echo "Removed worktree and pruned"
end
