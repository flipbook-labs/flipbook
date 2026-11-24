// The docs link between pages with relative Markdown links, which Obsidian,
// GitHub, and Docusaurus all follow. Obsidian writes `[[wikilinks]]` instead
// unless its link settings are changed, and Docusaurus would print those as
// literal text. This remark plugin fails the build when it finds one.
//
// Text nodes never include code, so a `[[` inside inline code or a code block
// is left alone.

import { visit } from "unist-util-visit";

export default function remarkNoWikilinks() {
	return function transformer(tree, file) {
		visit(tree, "text", (node) => {
			const match = node.value.match(/!?\[\[[^\]]+\]\]/);
			if (!match) return;
			file.fail(
				`Found the Obsidian wikilink ${match[0]}. Use a relative Markdown link to the .md file instead, like [Controls](../usage/controls.md).`,
				node,
			);
		});
	};
}
