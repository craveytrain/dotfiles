# fish module - show what process is listening on a given port
## What is running on provided port
## Currently mac only
function port
	lsof -n -i4TCP:$argv[1] | grep LISTEN
end
