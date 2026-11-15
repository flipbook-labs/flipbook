// Docusaurus remark plugin that expands `code-sample` fenced blocks into real
// code blocks, reading the referenced source file off disk at build time. The
// block body is a repo-root-relative path spec (optionally with a #Lstart-Lend
// line range); see the shared extractor for the spec grammar.
//
//   ```code-sample
//   workspace/code-samples/src/React/ReactButton.luau#L4-L13
//   ```
//
// Wired into docusaurus.config.ts via `beforeDefaultRemarkPlugins` alongside
// remark-obsidian, so the rewritten code block is then highlighted by
// Docusaurus's defaults. Extraction is shared with the Obsidian plugin via
// docs/code-samples/extract.mjs so the two surfaces can't drift.

import { visit } from "unist-util-visit";
import { resolve } from "node:path";

import {
	extractSample,
	CodeSampleError,
} from "../../../code-samples/extract.mjs";

export default function remarkCodeSample(options = {}) {
	const vault = options.vault;
	if (!vault)
		throw new Error("remarkCodeSample: the `vault` option is required");

	// The vault lives at docs/obsidian-vault, so the repo root (which path specs
	// are relative to) is two directories up.
	const repoRoot = resolve(vault, "..", "..");

	const warned = new Set();
	function warn(message) {
		if (warned.has(message)) return;
		warned.add(message);
		console.warn(`[remark-code-sample] ${message}`);
	}

	return function transformer(tree, file) {
		visit(tree, "code", (node) => {
			if (node.lang !== "code-sample") return;

			let result;
			try {
				result = extractSample({ repoRoot, spec: node.value });
			} catch (error) {
				if (error instanceof CodeSampleError) {
					warn(`${error.message} (in ${file.path})`);
					// Leave a visible marker rather than failing the whole build.
					node.lang = "text";
					node.meta = null;
					node.value = `[code-sample error] ${error.message}`;
					return;
				}
				throw error;
			}

			node.lang = result.lang || null;
			node.meta = `title="${result.title}"`;
			node.value = result.code;
		});
	};
}
