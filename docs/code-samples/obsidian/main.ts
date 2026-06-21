// Obsidian reading-view plugin that expands `code-sample` fenced blocks by
// reading the referenced source file off disk. It is the Obsidian counterpart to
// the Docusaurus remark adapter (docs/site/src/remark/code-sample.mjs); both call
// the same extractor (docs/code-samples/extract.mjs) so the two surfaces render
// identical code.
//
//   ```code-sample
//   workspace/code-samples/src/React/ReactButton.luau#L4-L13
//   ```
//
// Desktop only: it uses Node `fs` (via the shared extractor) to reach source
// files that live outside the vault, which the Obsidian vault adapter can't read.

import { resolve } from "node:path";
import {
	FileSystemAdapter,
	MarkdownRenderer,
	Plugin,
	type MarkdownPostProcessorContext,
} from "obsidian";

import { extractSample, CodeSampleError } from "../extract.mjs";

export default class CodeSamplePlugin extends Plugin {
	onload() {
		this.registerMarkdownCodeBlockProcessor("code-sample", (source, el, ctx) =>
			this.renderSample(source, el, ctx),
		);
	}

	private renderSample(
		source: string,
		el: HTMLElement,
		ctx: MarkdownPostProcessorContext,
	) {
		const repoRoot = this.repoRoot();
		if (!repoRoot) {
			this.renderError(el, "code-sample requires a desktop vault on disk");
			return;
		}

		let result;
		try {
			result = extractSample({ repoRoot, spec: source });
		} catch (error) {
			if (error instanceof CodeSampleError) {
				this.renderError(el, error.message);
				return;
			}
			throw error;
		}

		// Hand the resolved code back to Obsidian's own renderer as a normal
		// fenced block so it inherits native syntax highlighting and the copy
		// button. The render is async; the registered processor doesn't await it.
		const markdown = "```" + result.lang + "\n" + result.code + "\n```";
		void MarkdownRenderer.render(this.app, markdown, el, ctx.sourcePath, this);
	}

	/** Repo root that path specs are relative to: two levels above the vault. */
	private repoRoot(): string | null {
		const adapter = this.app.vault.adapter;
		if (!(adapter instanceof FileSystemAdapter)) return null;
		return resolve(adapter.getBasePath(), "..", "..");
	}

	private renderError(el: HTMLElement, message: string) {
		el.createDiv({ cls: "code-sample-error", text: `code-sample: ${message}` });
	}
}
