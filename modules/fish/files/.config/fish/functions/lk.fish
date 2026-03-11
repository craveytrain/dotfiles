# fish module - list files sorted by size, largest first
# Lists sorted by size, largest first.
function lk
	eza --long --header --icons --git --git-repos --sort=size  --reverse $argv
end
