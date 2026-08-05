#!/usr/bin/env node
// ai-usage-nudge.mjs — a gentle, once-per-session Stop hook that nudges the
// session to log meaningful AI work it hasn't recorded yet.
//
// Backstops the passive "AI usage logging" rule in ~/.claude/CLAUDE.md: a long
// session can forget mid-flow. This fires at most once per session, only when
// there's been meaningful edit activity and no AI_USAGE.md was touched, and only
// ever injects a NON-BLOCKING reminder (hookSpecificOutput.additionalContext) —
// it never blocks the stop or forces a loop.
//
// Registered under hooks.Stop in ~/.claude/settings.local.json (machine-local).
// To disable: remove that entry. Tunables via env:
//   AI_USAGE_NUDGE_MIN   meaningful edits required to nudge (default 3)
//   AI_USAGE_NUDGE_OFF   set to any value to disable entirely
//
// Fail-safe: any error exits 0 silently. A logging nudge must never break a turn.

import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join, resolve } from "node:path";

const EDIT_TOOLS = new Set(["Write", "Edit", "MultiEdit", "NotebookEdit"]);
const MIN_EDITS = Number(process.env.AI_USAGE_NUDGE_MIN || 3);
const MARKER_DIR = join(homedir(), ".claude", "cache", "ai-usage-nudge");

function done(output) {
  if (output) process.stdout.write(JSON.stringify(output));
  process.exit(0);
}

function readStdin() {
  try {
    return readFileSync(0, "utf8");
  } catch {
    return "";
  }
}

// Walk up from cwd to (and including) home, looking for a project CLAUDE.md that
// opts out. The global ~/.claude/CLAUDE.md is NOT a project file and is skipped.
function optedOut(cwd) {
  if (!cwd) return false;
  const home = resolve(homedir());
  const claudeDir = resolve(join(home, ".claude"));
  let dir = resolve(cwd);
  while (true) {
    if (dir !== claudeDir) {
      const f = join(dir, "CLAUDE.md");
      try {
        if (existsSync(f) && /no AI usage logging/i.test(readFileSync(f, "utf8"))) return true;
      } catch {}
    }
    if (dir === home || dir === "/") break;
    const parent = dirname(dir);
    if (parent === dir) break;
    dir = parent;
  }
  return false;
}

// Scan the session transcript (JSONL) for: count of edit-tool uses, and whether
// any AI_USAGE.md was touched (logged) this session. Best-effort and defensive
// about shape variation.
function scanTranscript(path) {
  let edits = 0;
  let logged = false;
  let text;
  try {
    text = readFileSync(path, "utf8");
  } catch {
    return { edits, logged };
  }
  for (const line of text.split("\n")) {
    if (!line.trim()) continue;
    let obj;
    try {
      obj = JSON.parse(line);
    } catch {
      continue;
    }
    const content = obj?.message?.content;
    if (!Array.isArray(content)) continue;
    for (const item of content) {
      if (item?.type !== "tool_use") continue;
      const name = item.name;
      const input = item.input || {};
      const fp = String(input.file_path || "");
      const cmd = String(input.command || "");
      if (/AI_USAGE\.md/.test(fp) || /AI_USAGE\.md/.test(cmd)) {
        logged = true;
        continue; // touching the log doesn't count as a "meaningful edit" to nudge about
      }
      if (EDIT_TOOLS.has(name)) edits++;
    }
  }
  return { edits, logged };
}

function main() {
  if (process.env.AI_USAGE_NUDGE_OFF) done();

  const raw = readStdin();
  let payload = {};
  try {
    payload = JSON.parse(raw);
  } catch {
    done();
  }

  // Only nudge the main agent's Stop, not subagent stops.
  if (payload.agent_id) done();

  const sessionId = payload.session_id;
  const transcript = payload.transcript_path;
  const cwd = payload.cwd || process.cwd();
  if (!sessionId || !transcript) done();

  // Once per session: if we've already nudged (or decided to stay quiet for an
  // opt-out), do nothing. Cheap stat, so every later Stop is a no-op.
  const marker = join(MARKER_DIR, sessionId);
  if (existsSync(marker)) done();

  if (optedOut(cwd)) {
    // Remember the decision so we don't rescan CLAUDE.md every turn.
    writeMarker(marker, "opted-out");
    done();
  }

  const { edits, logged } = scanTranscript(transcript);
  if (logged || edits < MIN_EDITS) {
    // Not yet worth nudging; leave the marker unset so a later, busier turn can
    // still trigger. (Once logged, this stays quiet for the rest of the session.)
    if (logged) writeMarker(marker, "already-logged");
    done();
  }

  writeMarker(marker, "nudged");
  done({
    hookSpecificOutput: {
      hookEventName: "Stop",
      additionalContext:
        "Meaningful work this session isn't reflected in the AI usage log. " +
        "If any AI contribution here is worth recording — especially an " +
        '"AI got it wrong" moment — append it now with the /log-ai skill. ' +
        "(If this project shouldn't be logged, ignore this.)",
    },
  });
}

function writeMarker(path, why) {
  try {
    mkdirSync(MARKER_DIR, { recursive: true });
    writeFileSync(path, why + "\n");
  } catch {}
}

main();
