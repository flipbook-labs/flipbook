// The docs mark notes, tips, and warnings with callouts: a blockquote whose
// first line is a type tag, like `> [!note] Optional title`. Obsidian and
// GitHub both render that syntax, but Docusaurus doesn't. This remark plugin
// turns each callout into the admonition directive Docusaurus draws as a
// colored box.
//
// It runs in `beforeDefaultRemarkPlugins`, ahead of Docusaurus's own
// admonition plugin, which then draws the directive nodes this creates.
// Obsidian's fold marker (`[!note]-`) is dropped, so collapsible callouts
// render as open boxes.

import { visit, SKIP } from "unist-util-visit";

// Obsidian has more callout types than Docusaurus has admonitions, so each
// callout type maps to the closest admonition. A type missing from this table,
// like `[!custom]`, renders as a note.
const CALLOUT_TYPES = {
	note: "note",
	abstract: "note",
	summary: "note",
	tldr: "note",
	todo: "note",
	example: "note",
	quote: "note",
	cite: "note",
	seealso: "note",
	tip: "tip",
	hint: "tip",
	important: "tip",
	success: "tip",
	check: "tip",
	done: "tip",
	info: "info",
	question: "info",
	help: "info",
	faq: "info",
	warning: "warning",
	caution: "warning",
	attention: "warning",
	danger: "danger",
	error: "danger",
	bug: "danger",
	failure: "danger",
	fail: "danger",
	missing: "danger",
};

export default function remarkCallouts() {
	return function transformer(tree) {
		visit(tree, "blockquote", (node, index, parent) => {
			if (index === null || !parent) return;
			const first = node.children[0];
			if (!first || first.type !== "paragraph") return;
			const text = first.children[0];
			if (!text || text.type !== "text") return;

			const m = text.value.match(
				/^\[!([a-zA-Z]+)\][+-]?[ \t]*([^\n]*)(\n[\s\S]*)?$/,
			);
			if (!m) return;

			const name = CALLOUT_TYPES[m[1].toLowerCase()] ?? "note";
			const title = m[2].trim();
			text.value = m[3] ? m[3].replace(/^\n/, "") : "";

			const children = [];
			if (title) {
				children.push({
					type: "paragraph",
					data: { directiveLabel: true },
					children: [{ type: "text", value: title }],
				});
			}
			children.push(...node.children);

			parent.children.splice(index, 1, {
				type: "containerDirective",
				name,
				attributes: {},
				children,
			});
			return [SKIP];
		});
	};
}
