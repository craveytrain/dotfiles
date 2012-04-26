# Quick shortcut to git.
#
# USAGE:
#
#   $ g
#   # => does a git status
#
#   $ g <command>
#   # => runs the associated command

g() {
	if [ "$#" -gt 0 ]; then
		git $@
	else
		git st
	fi
}