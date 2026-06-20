// A sidebarItemsGenerator that translates Obsidian conventions into the
// Docusaurus sidebar, the same way src/remark/obsidian.mjs translates
// Obsidian-flavored Markdown. The vault stays pure Obsidian; this does the
// Obsidian -> Docusaurus mapping at build time.
//
// Wired into docusaurus.config.ts via `docs.sidebarItemsGenerator`. It runs
// after the default autogeneration, then post-processes that tree to:
//
//   - Label each category from its index note's H1 (Docusaurus already labels
//     individual notes from theirs), humanizing the folder name as a fallback.
//   - Order items by the link order in each folder's index note — the Map of
//     Content the vault already maintains. The root order comes from README.md.
//     Anything a Map of Content doesn't list keeps the default order, so the
//     fallback is sidebar_position then alphabetical.
//   - Lead the root level with the docs home (README), relabelled to `homeLabel`
//     so it doesn't read as a second "Flipbook" next to the site title.

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

/** Normalize a vault path or wikilink target for case/space-insensitive matching. */
function normKey(rel) {
	return rel
		.toLowerCase()
		.replace(/\.md$/, "")
		.split("/")
		.map((seg) => seg.trim().replace(/\s+/g, "-"))
		.join("/");
}

/** A doc's vault-relative key (e.g. `usage/getting-started`), independent of a
 *  frontmatter `id` override, so it matches the paths wikilinks use. */
function relKeyOf(doc) {
	const src = doc.source.replace(/\\/g, "/");
	const marker = "/obsidian-vault/";
	const i = src.indexOf(marker);
	const rel = i >= 0 ? src.slice(i + marker.length) : src.replace(/^@site\//, "");
	return normKey(rel);
}

/** Ordered, normalized wikilink targets in a note, ignoring `![[embeds]]`. */
function mocOrder(absPath) {
	let text;
	try {
		text = readFileSync(absPath, "utf8");
	} catch {
		return [];
	}
	const targets = [];
	const pattern = /(?<!!)\[\[([^\]]+?)\]\]/g;
	let match;
	while ((match = pattern.exec(text)) !== null) {
		const target = match[1].split("|")[0].split("#")[0].trim();
		if (target) targets.push(normKey(target));
	}
	return targets;
}

export default function obsidianSidebarItems({ vault, homeLabel = "Overview" } = {}) {
	return async function generate({ defaultSidebarItemsGenerator, ...args }) {
		const items = await defaultSidebarItemsGenerator(args);
		const docById = new Map(args.docs.map((doc) => [doc.id, doc]));
		const relKeyById = new Map(args.docs.map((doc) => [doc.id, relKeyOf(doc)]));

		// The vault root's index note is README.md; it's the docs home at /docs/.
		const homeId = args.docs.find((doc) => relKeyOf(doc) === "readme")?.id;

		// Resolve a wikilink target to a canonical doc key the way Obsidian does:
		// an exact vault path, else the first note with that basename (so a Map of
		// Content can link `backend-stack` instead of `engineering/backend-stack`).
		const relKeys = new Set(relKeyById.values());
		const keyByName = new Map();
		for (const relKey of relKeys) {
			const name = relKey.split("/").pop();
			if (!keyByName.has(name)) keyByName.set(name, relKey);
		}
		function resolveTarget(target) {
			if (relKeys.has(target)) return target;
			return keyByName.get(target.split("/").pop()) ?? target;
		}

		/** The vault-relative dir a category covers, from its index note. */
		function dirOf(category) {
			const indexId = category.link?.type === "doc" ? category.link.id : undefined;
			const relKey = indexId ? relKeyById.get(indexId) : undefined;
			return relKey ? posix.dirname(relKey) : undefined;
		}

		/** Does an item's subtree contain the note a Map of Content link points to? */
		function owns(item, target) {
			if (item.type === "doc") return relKeyById.get(item.id) === target;
			if (item.type === "category") {
				const dir = dirOf(item);
				return dir !== undefined && (target === dir || target.startsWith(dir + "/"));
			}
			return false;
		}

		// `dir` is the vault-relative folder whose index note orders `list`
		// (`""` is the root, ordered by README.md).
		function process(list, dir) {
			const indexPath = dir === "" ? join(vault, "README.md") : join(vault, dir, "index.md");
			const order = mocOrder(indexPath).map(resolveTarget);

			const positioned = list.map((item, index) => {
				let rank = order.findIndex((target) => owns(item, target));
				if (rank === -1) rank = Infinity;
				// The home note leads the root level, ahead of the sections it maps.
				if (dir === "" && item.type === "doc" && item.id === homeId) rank = -1;
				return { item, rank, index };
			});
			// Stable: unlisted items keep the default sidebar_position/alpha order.
			positioned.sort((a, b) => a.rank - b.rank || a.index - b.index);

			return positioned.map(({ item }) => {
				if (item.type === "doc") {
					return item.id === homeId ? { ...item, label: homeLabel } : item;
				}
				if (item.type !== "category") return item;
				const indexId = item.link?.type === "doc" ? item.link.id : undefined;
				const label = (indexId && docById.get(indexId)?.title) || humanize(item.label);
				return { ...item, label, items: process(item.items, dirOf(item) ?? "") };
			});
		}

		return process(items, "");
	};
}
