# Prints headers of a URL
function headers
  curl -IL $argv[1]
end
