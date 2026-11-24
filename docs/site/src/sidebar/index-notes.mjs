// Each docs folder has an index note (`index.md`, or `README.md` at the root)
// that lists the folder's pages as links, in the order a reader should meet
// them. This sidebarItemsGenerator makes the sidebar follow those lists, so
// page order is set in one place that also reads well in Obsidian and on
// GitHub, instead of in `sidebar_position` frontmatter.
//
// It runs Docusaurus's default generator first, then reworks that tree:
//
//   - Each category is labeled with its index note's title (its H1, unless
//     frontmatter sets `title`), falling back to the folder name in Title Case.
//   - Items are sorted by where they first appear in the index note's links.
//     A subfolder ranks by the first link to any page inside it. Items the
//     note doesn't link keep the default order after the linked ones.
//   - A folder without an index note is ordered by the root README.md's links.
//   - The docs home (the root README.md) leads the root level, relabeled to
//     `homeLabel` so it doesn't read as a second "Flipbook" next to the site
//     title.

import { readFileSync } from "node:fs";
import { join, posix } from "node:path";

/** Turn a folder name like `migration-guides` into `Migration Guides`. */
function humanize(name) {
	return name
		.split(/[-_\s]+/)
		.filter(Boolean)
		.map((word) => word.charAt(0).toUpperCase() + word.slice(1))
		.join(" ");
}

/** A doc's path inside the docs folder without `.md`, like `usage/controls`. */
function relKeyOf(doc, docsDir) {
	const src = doc.source.replace(/\\/g, "/");
	const marker = `/${docsDir}/`;
	const i = src.indexOf(marker);
	const rel =
		i >= 0 ? src.slice(i + marker.length) : src.replace(/^@site\//, "");
	return rel.replace(/\.md$/, "");
}

/**
 * The pages an index note links to, in order, as paths like `usage/controls`.
 * Only relative links to `.md` files count, so images and external links are
 * skipped. `dir` is the index note's folder, which the links are relative to.
 */
function linkOrder(absPath, dir) {
	let text;
	try {
		text = readFileSync(absPath, "utf8");
	} catch {
		return [];
	}
	const targets = [];
	const pattern = /(?<!!)\[[^\]]*\]\(([^)#\s]+\.md)(?:#[^)]*)?\)/g;
	let match;
	while ((match = pattern.exec(text)) !== null) {
		if (/^[a-z]+:/i.test(match[1])) continue;
		const target = posix.normalize(
			posix.join(dir, decodeURIComponent(match[1])),
		);
		targets.push(target.replace(/\.md$/, ""));
	}
	return targets;
}

export default function indexNoteSidebarItems({
	docsPath,
	homeLabel = "Overview",
} = {}) {
	const docsDir = posix.basename(docsPath.replace(/\\/g, "/"));

	return async function generate({ defaultSidebarItemsGenerator, ...args }) {
		const items = await defaultSidebarItemsGenerator(args);
		const docById = new Map(args.docs.map((doc) => [doc.id, doc]));
		const relKeyById = new Map(
			args.docs.map((doc) => [doc.id, relKeyOf(doc, docsDir)]),
		);
		const homeId = args.docs.find(
			(doc) => relKeyOf(doc, docsDir) === "README",
		)?.id;

		/** The folder a category covers, found from its index note's path. */
		function dirOf(category) {
			const indexId =
				category.link?.type === "doc" ? category.link.id : undefined;
			const relKey = indexId ? relKeyById.get(indexId) : undefined;
			return relKey ? posix.dirname(relKey) : undefined;
		}

		/** Whether an item is the linked page, or a category that contains it. */
		function owns(item, target) {
			if (item.type === "doc") return relKeyById.get(item.id) === target;
			if (item.type === "category") {
				const dir = dirOf(item);
				return dir !== undefined && target.startsWith(dir + "/");
			}
			return false;
		}

		// `dir` is the folder whose index note orders `list`. The root is `"."`
		// and is ordered by README.md.
		function orderItems(list, dir) {
			const indexPath =
				dir === "."
					? join(docsPath, "README.md")
					: join(docsPath, dir, "index.md");
			const order = linkOrder(indexPath, dir);

			const positioned = list.map((item, index) => {
				let rank = order.findIndex((target) => owns(item, target));
				if (rank === -1) rank = Infinity;
				if (dir === "." && item.type === "doc" && item.id === homeId) rank = -1;
				return { item, rank, index };
			});
			positioned.sort((a, b) => a.rank - b.rank || a.index - b.index);

			return positioned.map(({ item }) => {
				if (item.type === "doc") {
					return item.id === homeId ? { ...item, label: homeLabel } : item;
				}
				if (item.type !== "category") return item;
				const indexId = item.link?.type === "doc" ? item.link.id : undefined;
				const label =
					(indexId && docById.get(indexId)?.title) || humanize(item.label);
				return {
					...item,
					label,
					items: orderItems(item.items, dirOf(item) ?? "."),
				};
			});
		}

		return orderItems(items, ".");
	};
}
