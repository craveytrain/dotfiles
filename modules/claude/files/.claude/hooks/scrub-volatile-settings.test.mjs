import { test } from "node:test";
import assert from "node:assert/strict";
import { mkdtempSync, readFileSync, rmSync, statSync, utimesSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { scrub, scrubFile } from "./scrub-volatile-settings.mjs";

const BASE = {
  permissions: { allow: ["Read(~/dotfiles/**)"] },
  hooks: { Stop: [{ hooks: [{ type: "command", command: "true" }] }] },
  theme: "auto",
};

function withFile(content, fn) {
  const dir = mkdtempSync(join(tmpdir(), "scrub-volatile-settings-"));
  try {
    const file = join(dir, "settings.json");
    writeFileSync(file, content);
    return fn(file);
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
}

test("strips each volatile key individually", () => {
  for (const key of ["model", "enabledPlugins", "autoMode"]) {
    const input = { ...BASE, [key]: "whatever" };
    const output = JSON.parse(scrub(`${JSON.stringify(input, null, 2)}\n`));
    assert.equal(Object.hasOwn(output, key), false);
    assert.deepEqual(output, BASE);
  }
});

test("strips all three volatile keys together", () => {
  const input = { ...BASE, model: "opus", enabledPlugins: ["foo"], autoMode: { environment: {} } };
  const output = JSON.parse(scrub(`${JSON.stringify(input, null, 2)}\n`));
  assert.deepEqual(output, BASE);
});

test("no-op when no volatile key is present: returns null", () => {
  assert.equal(scrub(`${JSON.stringify(BASE, null, 2)}\n`), null);
});

test("preserves unrelated keys and their order", () => {
  const input = { zeta: 1, model: "opus", alpha: 2, beta: 3 };
  const output = scrub(`${JSON.stringify(input, null, 2)}\n`);
  assert.equal(output, `${JSON.stringify({ zeta: 1, alpha: 2, beta: 3 }, null, 2)}\n`);
  assert.deepEqual(Object.keys(JSON.parse(output)), ["zeta", "alpha", "beta"]);
});

test("output is valid JSON with 2-space indent and a trailing newline", () => {
  const input = { ...BASE, model: "opus" };
  const output = scrub(`${JSON.stringify(input, null, 2)}\n`);
  assert.doesNotThrow(() => JSON.parse(output));
  assert.equal(output.endsWith("\n"), true);
  assert.equal(output, `${JSON.stringify(BASE, null, 2)}\n`);
});

test("unparseable JSON returns null (pure transform)", () => {
  assert.equal(scrub("{ not json"), null);
});

test("scrubFile: no-op when absent — file content and mtime unchanged", () => {
  withFile(`${JSON.stringify(BASE, null, 2)}\n`, (file) => {
    const before = readFileSync(file, "utf8");
    const mtimeBefore = statSync(file).mtimeMs;
    scrubFile(file);
    assert.equal(readFileSync(file, "utf8"), before);
    assert.equal(statSync(file).mtimeMs, mtimeBefore);
  });
});

test("scrubFile: missing file is a silent no-op", () => {
  withFile(`${JSON.stringify(BASE, null, 2)}\n`, (file) => {
    const missing = `${file}.does-not-exist`;
    assert.doesNotThrow(() => scrubFile(missing));
  });
});

test("scrubFile: unparseable JSON leaves the file byte-identical", () => {
  const raw = "{ not json, definitely broken";
  withFile(raw, (file) => {
    scrubFile(file);
    assert.equal(readFileSync(file, "utf8"), raw);
  });
});

test("scrubFile: strips a volatile key and rewrites the file", () => {
  const input = { ...BASE, model: "opus" };
  withFile(`${JSON.stringify(input, null, 2)}\n`, (file) => {
    scrubFile(file);
    const after = readFileSync(file, "utf8");
    assert.equal(after, `${JSON.stringify(BASE, null, 2)}\n`);
    assert.doesNotThrow(() => JSON.parse(after));
  });
});

test("scrubFile: backdated mtime proves a genuine no-op leaves the file untouched", () => {
  withFile(`${JSON.stringify(BASE, null, 2)}\n`, (file) => {
    const past = new Date(Date.now() - 10 * 60 * 1000);
    utimesSync(file, past, past);
    const mtimeBefore = statSync(file).mtimeMs;
    scrubFile(file);
    assert.equal(statSync(file).mtimeMs, mtimeBefore);
  });
});
