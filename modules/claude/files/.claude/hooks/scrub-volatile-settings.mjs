#!/usr/bin/env node
// scrub-volatile-settings.mjs — a SessionEnd hook that strips volatile,
// machine-local keys out of the git-tracked ~/.claude/settings.json before
// the session exits.
//
// Claude Code writes its own runtime state (in-session model step-ups,
// enabled plugins, auto-mode config) directly into settings.json. Because
// that file is stowed from this repo, anything left there gets committed —
// and this repo is public. SessionEnd (not SessionStart, not Stop) is
// deliberate: SessionStart runs after settings are already read, and Stop
// fires every assistant turn, which would rip out a deliberate in-session
// step-up while the session is still running.
//
// Registered under hooks.SessionEnd in the Claude Code settings.json. To
// disable: remove that entry.
//
// Fail-safe: any error exits 0 silently. A cleanup hook must never break
// session exit.

import { existsSync, readFileSync, realpathSync, renameSync, rmSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { pathToFileURL } from "node:url";

const VOLATILE_KEYS = ["model", "enabledPlugins", "autoMode"];
const SETTINGS_PATH = join(homedir(), ".claude", "settings.json");

function readStdin() {
  try {
    readFileSync(0, "utf8");
  } catch {
    // no stdin to read; ignore
  }
}

// Pure transform: strips VOLATILE_KEYS from a settings.json string, preserving
// key order and 2-space/trailing-newline formatting. Returns null when no
// volatile key is present (caller should no-op) or the input isn't valid JSON.
export function scrub(text) {
  let parsed;
  try {
    parsed = JSON.parse(text);
  } catch {
    return null;
  }
  if (typeof parsed !== "object" || parsed === null || Array.isArray(parsed)) return null;

  const present = VOLATILE_KEYS.filter((key) => Object.prototype.hasOwnProperty.call(parsed, key));
  if (present.length === 0) return null;

  for (const key of present) delete parsed[key];

  const output = `${JSON.stringify(parsed, null, 2)}\n`;

  // Re-parse before handing back, so we never write something we can't read.
  try {
    JSON.parse(output);
  } catch {
    return null;
  }

  return output;
}

// File-level wrapper around scrub(): reads path, and iff a volatile key was
// present, atomically rewrites it. Silent no-op on any error (missing file,
// unparseable JSON, read-only FS). Exported (mirrors scanTranscript(path) in
// ai-usage-nudge.mjs) so tests can point it at a throwaway file instead of
// the real ~/.claude/settings.json.
export function scrubFile(path) {
  let text;
  try {
    text = readFileSync(path, "utf8");
  } catch {
    return; // missing or unreadable file: silent no-op
  }

  const output = scrub(text);
  if (output === null) return; // no volatile keys present, or unparseable: leave untouched

  // ~/.claude/settings.json is a symlink into the dotfiles repo. Resolve it
  // (dynamically — never a hardcoded repo path) purely to find where the
  // atomic temp file + rename must land: the real file's directory. Renaming
  // onto the symlink path itself would replace the symlink with a plain file
  // instead of writing through it.
  let tmpPath;
  try {
    const realPath = realpathSync(path);
    tmpPath = join(dirname(realPath), `.settings.json.${process.pid}.scrub-tmp`);
    writeFileSync(tmpPath, output);
    renameSync(tmpPath, realPath);
  } catch {
    // Read-only filesystem, permissions, etc. A failed rename would otherwise
    // orphan the temp file inside the repo as untracked cruft.
    try {
      if (tmpPath) rmSync(tmpPath, { force: true });
    } catch {}
  }
}

function main() {
  readStdin();
  if (existsSync(SETTINGS_PATH)) scrubFile(SETTINGS_PATH);
  process.exit(0);
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) main();
