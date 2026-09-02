# dev-tools module - abbreviations for on-demand npx tools
#
# These are packages worth running but not worth installing. The abbr expands
# in place so the real command stays visible, and `abbr | grep npx` lists
# everything here when memory fails.

if status --is-interactive
    # interactive dependency upgrades: npm-check-updates
    abbr -a ncu 'npx npm-check-updates --interactive'

    # find and delete node_modules directories by size
    abbr -a npkill 'npx npkill'

    # report unused files, exports and dependencies
    abbr -a knip 'npx knip'

    # lint package.json for publishing mistakes (exports maps, missing files)
    abbr -a publint 'npx publint'

    # check published types resolve under both ESM and CJS; add --pack in a package dir
    abbr -a attw 'npx @arethetypeswrong/cli'

    # scaffold from a repo's contents without its git history
    abbr -a degit 'npx degit'
end
