#!/usr/bin/env node
// Claude Code Statusline - Custom with p10k-style git status
// Shows: model | git status | current task | directory | context usage

const fs = require('fs')
const path = require('path')
const os = require('os')
const { execSync } = require('child_process')

// ANSI color codes matching p10k 8-color theme
const colors = {
	reset: '\x1b[0m',
	dim: '\x1b[2m',
	bold: '\x1b[1m',
	green: '\x1b[32m', // clean
	yellow: '\x1b[33m', // modified/staged/unstaged
	blue: '\x1b[34m', // untracked
	red: '\x1b[31m', // conflicted
	cyan: '\x1b[36m', // meta/default
}

// Icons (Nerd Font)
const icons = {
	branch: '\uf126', //
	tag: '\uf02b', //
	commit: '\uf417', //
	github: '\uf09b', //
	gitlab: '\uf296', //
	bitbucket: '\uf171', //
	git: '\ue702', //
}

function execGit(args, cwd) {
	try {
		return execSync(`git ${args}`, {
			cwd,
			encoding: 'utf8',
			stdio: ['pipe', 'pipe', 'pipe'],
		}).trim()
	} catch {
		return ''
	}
}

function getGitStatus(cwd) {
	// Check if in a git repo
	const gitDir = execGit('rev-parse --git-dir', cwd)
	if (!gitDir) return null

	const status = {}

	// Get branch, tag, or commit
	status.branch = execGit('symbolic-ref --short HEAD', cwd)
	if (!status.branch) {
		// Detached HEAD - check for tag
		status.tag = execGit('describe --tags --exact-match HEAD', cwd)
		if (!status.tag) {
			// Just show commit hash
			status.commit = execGit('rev-parse --short HEAD', cwd)
		}
	}

	// Check for remote origin type (GitHub, GitLab, etc.)
	const remoteUrl = execGit('config --get remote.origin.url', cwd)
	if (remoteUrl) {
		if (remoteUrl.includes('github.com')) {
			status.remote = 'github'
		} else if (remoteUrl.includes('gitlab.com')) {
			status.remote = 'gitlab'
		} else if (remoteUrl.includes('bitbucket.org')) {
			status.remote = 'bitbucket'
		} else {
			status.remote = 'git'
		}
	}

	// Get ahead/behind counts
	const upstream = execGit('rev-parse --abbrev-ref @{upstream}', cwd)
	if (upstream) {
		const aheadBehind = execGit(
			'rev-list --left-right --count HEAD...@{upstream}',
			cwd
		)
		if (aheadBehind) {
			const [ahead, behind] = aheadBehind.split(/\s+/).map(Number)
			status.ahead = ahead || 0
			status.behind = behind || 0
		}
	}

	// Get push remote ahead/behind (if different from upstream)
	const pushRemote = execGit('rev-parse --abbrev-ref @{push}', cwd)
	if (pushRemote && pushRemote !== upstream) {
		const pushAheadBehind = execGit(
			'rev-list --left-right --count HEAD...@{push}',
			cwd
		)
		if (pushAheadBehind) {
			const [ahead, behind] = pushAheadBehind.split(/\s+/).map(Number)
			status.pushAhead = ahead || 0
			status.pushBehind = behind || 0
		}
	}

	// Get stash count
	const stashList = execGit('stash list', cwd)
	status.stashes = stashList ? stashList.split('\n').filter(Boolean).length : 0

	// Check for action (merge, rebase, etc.)
	const gitDirPath = execGit('rev-parse --absolute-git-dir', cwd)
	if (gitDirPath) {
		if (fs.existsSync(path.join(gitDirPath, 'MERGE_HEAD'))) {
			status.action = 'merge'
		} else if (
			fs.existsSync(path.join(gitDirPath, 'rebase-merge')) ||
			fs.existsSync(path.join(gitDirPath, 'rebase-apply'))
		) {
			status.action = 'rebase'
		} else if (fs.existsSync(path.join(gitDirPath, 'CHERRY_PICK_HEAD'))) {
			status.action = 'cherry-pick'
		} else if (fs.existsSync(path.join(gitDirPath, 'BISECT_LOG'))) {
			status.action = 'bisect'
		}
	}

	// Get status counts using porcelain format
	const porcelain = execGit('status --porcelain=v1', cwd)
	status.staged = 0
	status.unstaged = 0
	status.untracked = 0
	status.conflicted = 0

	if (porcelain) {
		for (const line of porcelain.split('\n')) {
			if (!line) continue
			const x = line[0] // staged
			const y = line[1] // unstaged

			// Conflicts
			if (
				x === 'U' ||
				y === 'U' ||
				(x === 'A' && y === 'A') ||
				(x === 'D' && y === 'D')
			) {
				status.conflicted++
			} else {
				// Staged changes
				if (x !== ' ' && x !== '?') {
					status.staged++
				}
				// Unstaged changes
				if (y !== ' ' && y !== '?') {
					status.unstaged++
				}
				// Untracked
				if (x === '?' && y === '?') {
					status.untracked++
				}
			}
		}
	}

	// Check for wip in commit message
	const commitMsg = execGit('log -1 --format=%s', cwd)
	status.wip = /\bwip\b/i.test(commitMsg)

	return status
}

function formatGitStatus(status) {
	if (!status) return ''

	const parts = []

	// Remote icon (GitHub, GitLab, etc.)
	if (status.remote) {
		const remoteIcon = icons[status.remote] || icons.git
		parts.push(`${colors.dim}${remoteIcon}${colors.reset}`)
	}

	// Branch/tag/commit with icon
	let refPart = ''
	if (status.branch) {
		let branch = status.branch
		// Truncate long branch names: first 12 + … + last 12
		if (branch.length > 32) {
			branch = branch.slice(0, 12) + '…' + branch.slice(-12)
		}
		refPart = `${colors.green}${icons.branch} ${branch}${colors.reset}`
	} else if (status.tag) {
		let tag = status.tag
		if (tag.length > 32) {
			tag = tag.slice(0, 12) + '…' + tag.slice(-12)
		}
		refPart = `${colors.green}${icons.tag}${tag}${colors.reset}`
	} else if (status.commit) {
		refPart = `${colors.green}${icons.commit}${status.commit}${colors.reset}`
	}
	if (refPart) parts.push(refPart)

	// Wip indicator
	if (status.wip) {
		parts.push(`${colors.yellow}wip${colors.reset}`)
	}

	// Ahead/behind remote
	const syncParts = []
	if (status.behind) {
		syncParts.push(`${colors.green}⇣${status.behind}${colors.reset}`)
	}
	if (status.ahead) {
		syncParts.push(`${colors.green}⇡${status.ahead}${colors.reset}`)
	}
	if (syncParts.length) parts.push(syncParts.join(''))

	// Push remote ahead/behind
	const pushParts = []
	if (status.pushBehind) {
		pushParts.push(`${colors.green}⇠${status.pushBehind}${colors.reset}`)
	}
	if (status.pushAhead) {
		pushParts.push(`${colors.green}⇢${status.pushAhead}${colors.reset}`)
	}
	if (pushParts.length) parts.push(pushParts.join(''))

	// Stashes
	if (status.stashes) {
		parts.push(`${colors.green}*${status.stashes}${colors.reset}`)
	}

	// Action (merge, rebase, etc.)
	if (status.action) {
		parts.push(`${colors.red}${status.action}${colors.reset}`)
	}

	// Conflicts
	if (status.conflicted) {
		parts.push(`${colors.red}~${status.conflicted}${colors.reset}`)
	}

	// Staged
	if (status.staged) {
		parts.push(`${colors.yellow}+${status.staged}${colors.reset}`)
	}

	// Unstaged
	if (status.unstaged) {
		parts.push(`${colors.yellow}!${status.unstaged}${colors.reset}`)
	}

	// Untracked
	if (status.untracked) {
		parts.push(`${colors.blue}?${status.untracked}${colors.reset}`)
	}

	return parts.join(' ')
}

// Read JSON from stdin
let input = ''
process.stdin.setEncoding('utf8')
process.stdin.on('data', chunk => (input += chunk))
process.stdin.on('end', () => {
	try {
		const data = JSON.parse(input)
		const model = data.model?.display_name || 'Claude'
		const dir = data.workspace?.current_dir || process.cwd()
		const session = data.session_id || ''
		const remaining = data.context_window?.remaining_percentage

		// Context window display (shows USED percentage scaled to 80% limit)
		// Claude Code enforces an 80% context limit, so we scale to show 100% at that point
		let ctx = ''
		if (remaining != null) {
			const rem = Math.round(remaining)
			const rawUsed = Math.max(0, Math.min(100, 100 - rem))
			// Scale: 80% real usage = 100% displayed
			const used = Math.min(100, Math.round((rawUsed / 80) * 100))

			// Build progress bar (10 segments)
			const filled = Math.floor(used / 10)
			const bar = '\u2588'.repeat(filled) + '\u2591'.repeat(10 - filled)

			// Color based on scaled usage (thresholds adjusted for new scale)
			if (used < 63) {
				// ~50% real
				ctx = ` ${colors.green}${bar} ${used}%${colors.reset}`
			} else if (used < 81) {
				// ~65% real
				ctx = ` ${colors.yellow}${bar} ${used}%${colors.reset}`
			} else if (used < 95) {
				// ~76% real
				ctx = ` \x1b[38;5;208m${bar} ${used}%${colors.reset}`
			} else {
				ctx = ` \x1b[5;31m\u{1F480} ${bar} ${used}%${colors.reset}`
			}
		}

		// Current task from todos
		let task = ''
		const homeDir = os.homedir()
		const todosDir = path.join(homeDir, '.claude', 'todos')
		if (session && fs.existsSync(todosDir)) {
			const files = fs
				.readdirSync(todosDir)
				.filter(
					f =>
						f.startsWith(session) &&
						f.includes('-agent-') &&
						f.endsWith('.json')
				)
				.map(f => ({
					name: f,
					mtime: fs.statSync(path.join(todosDir, f)).mtime,
				}))
				.sort((a, b) => b.mtime - a.mtime)

			if (files.length > 0) {
				try {
					const todos = JSON.parse(
						fs.readFileSync(path.join(todosDir, files[0].name), 'utf8')
					)
					const inProgress = todos.find(t => t.status === 'in_progress')
					if (inProgress) task = inProgress.activeForm || ''
				} catch (e) {}
			}
		}

		// GSD update available?
		let gsdUpdate = ''
		const cacheFile = path.join(
			homeDir,
			'.claude',
			'cache',
			'gsd-update-check.json'
		)
		if (fs.existsSync(cacheFile)) {
			try {
				const cache = JSON.parse(fs.readFileSync(cacheFile, 'utf8'))
				if (cache.update_available) {
					gsdUpdate = `${colors.yellow}\u2B06 /gsd:update${colors.reset} \u2502 `
				}
			} catch (e) {}
		}

		// Git status
		const gitStatus = getGitStatus(dir)
		const gitPart = formatGitStatus(gitStatus)

		// Output - Order: model │ dir + git │ task │ context usage
		const dirname = path.basename(dir)
		const parts = []

		// Always show model first
		parts.push(`${colors.dim}${model}${colors.reset}`)

		// Directory and git info together
		const dirGitParts = [`${colors.dim}${dirname}${colors.reset}`]
		if (gitPart) {
			dirGitParts.push(gitPart)
		}
		parts.push(dirGitParts.join(' '))

		// Task (only if present)
		if (task) {
			parts.push(`${colors.bold}${task}${colors.reset}`)
		}

		// Context usage (only if present)
		if (ctx) {
			parts.push(ctx.trim())
		}

		// Prepend GSD update if available
		const output = gsdUpdate
			? gsdUpdate + parts.join(' \u2502 ')
			: parts.join(' \u2502 ')
		process.stdout.write(output)
	} catch (e) {
		// Silent fail - don't break statusline on parse errors
	}
})
