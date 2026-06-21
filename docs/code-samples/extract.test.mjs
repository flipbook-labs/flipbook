// Unit tests for the shared code-sample extractor. Run with:
//   node --test docs/code-samples/
// Uses a throwaway fixture directory as the repo root so the tests don't depend
// on the contents of real sample files.

import { test, before, after } from "node:test";
import assert from "node:assert/strict";
import { mkdtempSync, writeFileSync, rmSync, mkdirSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

import {
	extractSample,
	parseSpec,
	dedent,
	CodeSampleError,
} from "./extract.mjs";

let repoRoot;

// A sample whose body is indented one tab, so range extraction exercises dedent.
const SAMPLE = [
	'local React = require("@pkg/React")',
	"",
	"local function Button()",
	'\treturn React.createElement("TextButton", {',
	'\t\tText = "Click Me",',
	"\t})",
	"end",
	"",
	"return Button",
	"",
].join("\n");

before(() => {
	repoRoot = mkdtempSync(join(tmpdir(), "code-sample-"));
	mkdirSync(join(repoRoot, "samples"));
	writeFileSync(join(repoRoot, "samples", "Button.luau"), SAMPLE);
});

after(() => {
	rmSync(repoRoot, { recursive: true, force: true });
});

test("whole file: returns the file with a single trailing newline trimmed", () => {
	const result = extractSample({ repoRoot, spec: "samples/Button.luau" });
	assert.equal(result.lang, "lua");
	assert.equal(result.title, "Button.luau");
	assert.equal(result.sourcePath, "samples/Button.luau");
	assert.equal(result.code.endsWith("return Button"), true);
	assert.equal(result.code.includes("local React"), true);
});

test("line range: slices inclusive and dedents the common indent", () => {
	const result = extractSample({ repoRoot, spec: "samples/Button.luau#L4-L6" });
	assert.equal(
		result.code,
		[
			'return React.createElement("TextButton", {',
			'\tText = "Click Me",',
			"})",
		].join("\n"),
	);
});

test("single line: #L7 returns just that line", () => {
	const result = extractSample({ repoRoot, spec: "samples/Button.luau#L7" });
	assert.equal(result.code, "end");
});

test("parseSpec: whole file has no range", () => {
	assert.deepEqual(parseSpec("a/b.luau"), { path: "a/b.luau", range: null });
});

test("parseSpec: accepts #L7 and #L7-L13 and #L7-13", () => {
	assert.deepEqual(parseSpec("x#L7").range, { start: 7, end: 7 });
	assert.deepEqual(parseSpec("x#L7-L13").range, { start: 7, end: 13 });
	assert.deepEqual(parseSpec("x#L7-13").range, { start: 7, end: 13 });
});

test("dedent: strips common leading whitespace, ignores blank lines", () => {
	assert.deepEqual(dedent(["\t\ta", "", "\t\t\tb"]), ["a", "", "\tb"]);
});

test("error: empty spec", () => {
	assert.throws(() => parseSpec("  "), CodeSampleError);
});

test("error: malformed range fragment", () => {
	assert.throws(() => parseSpec("x#nonsense"), CodeSampleError);
	assert.throws(() => parseSpec("x#L0"), CodeSampleError);
	assert.throws(() => parseSpec("x#L9-L2"), CodeSampleError);
});

test("error: missing file", () => {
	assert.throws(
		() => extractSample({ repoRoot, spec: "samples/Missing.luau" }),
		CodeSampleError,
	);
});

test("error: range past end of file", () => {
	assert.throws(
		() => extractSample({ repoRoot, spec: "samples/Button.luau#L1-L999" }),
		CodeSampleError,
	);
});
