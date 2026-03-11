# fish module - list all files in long format with git status
# Lists human readable sizes, hidden files.
function la
	eza --long --header --all --icons --git --git-repos $argv
end
