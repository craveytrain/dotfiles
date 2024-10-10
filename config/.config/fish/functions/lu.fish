# Lists sorted by modified timestamp, most recent first
function lu
	eza --long --header --icons --git --git-repos --time-style=relative --sort=modified --reverse $argv
end
