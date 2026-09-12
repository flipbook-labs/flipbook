// Shared extraction logic for `code-sample` blocks, used by both the Docusaurus
// remark adapter (docs/site/src/remark/code-sample.mjs) and the Obsidian
// reading-view plugin (docs/code-samples/obsidian/). Keeping it here, framework
// agnostic and dependency free, ensures the two surfaces never diverge.
//
// A spec is a repo-root-relative path with an optional line-range fragment:
//
//   workspace/code-samples/src/React/ReactButton.luau        whole file
//   workspace/code-samples/src/React/ReactButton.luau#L7-L13  lines 7-13
//   workspace/code-samples/src/React/ReactButton.luau#L7      single line 7

import { readFileSync } from "node:fs";
import { resolve, basename, extname } from "node:path";

// Source extension -> Prism/Obsidian highlighting language. Prism has no `luau`,
// and docs/site registers `lua` via `additionalLanguages`, so we map onto that.
const LANG_BY_EXT = {
	".luau": "lua",
	".lua": "lua",
};

/** Thrown for any author-facing problem (bad spec, missing file, bad range). */
export class CodeSampleError extends Error {}

/** Split a spec into its path and optional `{ start, end }` line range. */
export function parseSpec(spec) {
	const trimmed = (spec ?? "").trim();
	if (!trimmed) throw new CodeSampleError("empty code-sample spec");

	const hash = trimmed.indexOf("#");
	if (hash === -1) return { path: trimmed, range: null };

	const path = trimmed.slice(0, hash);
	const fragment = trimmed.slice(hash + 1);
	const match = fragment.match(/^L(\d+)(?:-L?(\d+))?$/);
	if (!match) {
		throw new CodeSampleError(
			`invalid line range "#${fragment}" (expected #L<start> or #L<start>-L<end>)`,
		);
	}

	const start = Number(match[1]);
	const end = match[2] ? Number(match[2]) : start;
	if (start < 1 || end < start) {
		throw new CodeSampleError(`invalid line range "#${fragment}"`);
	}
	return { path, range: { start, end } };
}

/** Remove the common leading whitespace shared by all non-blank lines. */
export function dedent(lines) {
	let min = Infinity;
	for (const line of lines) {
		if (line.trim().length === 0) continue;
		min = Math.min(min, line.match(/^[\t ]*/)[0].length);
	}
	if (!Number.isFinite(min) || min === 0) return lines;
	return lines.map((line) => line.slice(min));
}

/**
 * Resolve a `code-sample` spec to the code it should render.
 *
 * @param {{ repoRoot: string, spec: string }} options
 * @returns {{ code: string, lang: string, sourcePath: string, title: string }}
 */
export function extractSample({ repoRoot, spec }) {
	const { path, range } = parseSpec(spec);

	let raw;
	try {
		raw = readFileSync(resolve(repoRoot, path), "utf8");
	} catch {
		throw new CodeSampleError(`code sample not found: ${path}`);
	}

	// Normalize line endings and drop a single trailing newline so the rendered
	// block doesn't carry a blank final line.
	let lines = raw.replace(/\r\n/g, "\n").replace(/\n$/, "").split("\n");

	if (range) {
		if (range.end > lines.length) {
			throw new CodeSampleError(
				`line range #L${range.start}-L${range.end} exceeds ${path} (${lines.length} lines)`,
			);
		}
		lines = lines.slice(range.start - 1, range.end);
	}

	return {
		code: dedent(lines).join("\n"),
		lang: LANG_BY_EXT[extname(path).toLowerCase()] ?? "",
		sourcePath: path,
		title: basename(path),
	};
}
