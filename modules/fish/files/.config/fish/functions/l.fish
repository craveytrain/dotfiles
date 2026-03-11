# fish module - list files in one column with hidden files
# Lists in one column, hidden files.
function l
	eza --oneline --all --icons $argv
end
