# fish module - list files using eza with classify and grid layout
# if eza is installed, used it
function ls
	eza -F -x $argv
end
