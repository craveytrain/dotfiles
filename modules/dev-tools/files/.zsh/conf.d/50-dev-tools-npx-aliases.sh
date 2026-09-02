# shellcheck shell=zsh
# dev-tools module - aliases for on-demand npx tools
#
# Mirrors .config/fish/conf.d/50-dev-tools-npx-abbrs.fish. These are packages
# worth running but not worth installing.

# interactive dependency upgrades: npm-check-updates
alias ncu='npx npm-check-updates --interactive'

# find and delete node_modules directories by size
alias npkill='npx npkill'

# report unused files, exports and dependencies
alias knip='npx knip'

# lint package.json for publishing mistakes (exports maps, missing files)
alias publint='npx publint'

# check published types resolve under both ESM and CJS; add --pack in a package dir
alias attw='npx @arethetypeswrong/cli'

# scaffold from a repo's contents without its git history
alias degit='npx degit'
