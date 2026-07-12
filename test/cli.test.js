import { test } from "node:test";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import path from "node:path";

const CLI_PATH = path.join(
  path.dirname(fileURLToPath(import.meta.url)),
  "../bin/conv.js"
);

function runCli(args) {
  return spawnSync("node", [CLI_PATH, ...args], { encoding: "utf8" });
}

test("basic length conversion", () => {
  const { stdout, status } = runCli(["100", "km", "mi"]);
  assert.equal(status, 0);
  assert.equal(stdout.trim(), "62.1371");
});

test("basic temperature conversion", () => {
  const { stdout, status } = runCli(["32", "f", "c"]);
  assert.equal(status, 0);
  assert.equal(stdout.trim(), "0");
});

test("--precision option controls decimal places", () => {
  const { stdout, status } = runCli(["100", "km", "mi", "--precision", "2"]);
  assert.equal(status, 0);
  assert.equal(stdout.trim(), "62.14");
});

test("--list prints unit categories", () => {
  const { stdout, status } = runCli(["--list"]);
  assert.equal(status, 0);
  assert.match(stdout, /length:/);
  assert.match(stdout, /mass:/);
  assert.match(stdout, /temperature:/);
});

test("missing arguments shows usage and exits 1", () => {
  const { stderr, status } = runCli([]);
  assert.equal(status, 1);
  assert.match(stderr, /Usage: conv/);
});

test("invalid number reports an error", () => {
  const { stderr, status } = runCli(["abc", "km", "mi"]);
  assert.equal(status, 1);
  assert.match(stderr, /not a valid number/);
});

test("unknown unit reports an error", () => {
  const { stderr, status } = runCli(["1", "xx", "km"]);
  assert.equal(status, 1);
  assert.match(stderr, /unknown unit/);
});

test("mismatched categories reports an error", () => {
  const { stderr, status } = runCli(["1", "km", "kg"]);
  assert.equal(status, 1);
  assert.match(stderr, /cannot convert/);
});
