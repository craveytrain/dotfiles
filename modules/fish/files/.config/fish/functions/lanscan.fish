# Scans the local network for active hosts
function lanscan
		set IP (ipconfig getifaddr en0)
		nmap -sn $IP/24
end
