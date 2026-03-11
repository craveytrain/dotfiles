# fish module - list files sorted by modification time, most recent first
# Lists sorted by modified timestamp, most recent first
function lu
	eza --long --header --icons --git --git-repos --time-style=relative --sort=modified --reverse $argv
end
