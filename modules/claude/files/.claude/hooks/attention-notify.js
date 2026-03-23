#!/usr/bin/env node
// Notify when Claude Code is waiting for user attention
// Triggers: macOS notification + terminal bell (Ghostty persistent tab badge + dock bounce)
// Hook event: Notification (idle_prompt, permission_prompt)

const { execSync } = require('child_process')
const fs = require('fs')

let input = ''
const timeout = setTimeout(() => process.exit(0), 3000)
process.stdin.setEncoding('utf8')
process.stdin.on('data', chunk => (input += chunk))
process.stdin.on('end', () => {
	clearTimeout(timeout)
	try {
		const data = JSON.parse(input)
		const type = data.notification_type

		// Only notify for states where Claude is waiting on the user
		if (type !== 'idle_prompt' && type !== 'permission_prompt') {
			return
		}

		const message = type === 'permission_prompt'
			? data.message || 'Claude needs your approval to continue'
			: data.message || 'Claude has finished and is waiting for you'

		const notifTitle = type === 'permission_prompt'
			? 'Claude Code - Permission Needed'
			: 'Claude Code - Ready for Input'

		// Terminal bell - find the TTY by walking up the process tree
		// In Ghostty with bell-features=attention,title this triggers:
		//   1. Persistent bell emoji on tab title (stays until tab is focused)
		//   2. Dock icon bounce (when Ghostty is not the focused app)
		const tty = findTTY()
		if (tty) {
			try {
				fs.writeFileSync(tty, '\x07')
			} catch {}
		}
	} catch {}
})

function findTTY() {
	try {
		let pid = process.ppid
		for (let i = 0; i < 10; i++) {
			const info = execSync(`ps -o tty=,ppid= -p ${pid}`, {
				encoding: 'utf8',
				stdio: ['pipe', 'pipe', 'pipe'],
			}).trim()
			const parts = info.split(/\s+/)
			const tty = parts[0]
			if (tty && tty !== '??' && tty !== '???') {
				return `/dev/${tty}`
			}
			pid = parseInt(parts[1])
			if (!pid || isNaN(pid) || pid <= 1) break
		}
	} catch {}
	return null
}

function escapeAppleScript(str) {
	return '"' + str.replace(/\\/g, '\\\\').replace(/"/g, '\\"') + '"'
}
