import { test } from "node:test";
import assert from "node:assert/strict";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { scanTranscript } from "./ai-usage-nudge.mjs";

function scan(lines) {
  const dir = mkdtempSync(join(tmpdir(), "ai-usage-nudge-"));
  try {
    const file = join(dir, "session.jsonl");
    writeFileSync(file, `${lines.map((line) => JSON.stringify(line)).join("\n")}\n`);
    return scanTranscript(file);
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
}

test("counts Claude and Codex edits", () => {
  assert.deepEqual(scan([
    { type: "assistant", message: { content: [{ type: "tool_use", name: "Edit", input: { file_path: "/tmp/a" } }] } },
    { type: "response_item", payload: { type: "custom_tool_call", name: "exec", input: "await tools.apply_patch(\"*** Begin Patch\")" } },
    { type: "response_item", payload: { type: "function_call", name: "apply_patch", arguments: { patch: "*** Begin Patch" } } },
  ]), { edits: 3, logged: false });
});

test("detects either harness touching AI_USAGE.md without counting it as an edit", () => {
  assert.deepEqual(scan([
    { type: "assistant", message: { content: [{ type: "tool_use", name: "Edit", input: { file_path: "/repo/AI_USAGE.md" } }] } },
    { type: "response_item", payload: { type: "custom_tool_call", name: "exec", input: "await tools.apply_patch(\"Update File: /repo/AI_USAGE.md\")" } },
  ]), { edits: 0, logged: true });
});
