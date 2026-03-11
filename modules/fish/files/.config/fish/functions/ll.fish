# fish module - list files in long format with git status
# Lists human readable sizes.
function ll
	eza --long --header --icons --git --git-repos $argv
end
