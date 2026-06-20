// A sidebarItemsGenerator that translates Obsidian conventions into the
// Docusaurus sidebar, the same way src/remark/obsidian.mjs translates
// Obsidian-flavored Markdown. The vault stays pure Obsidian; this does the
// Obsidian -> Docusaurus mapping at build time.
//
// Wired into docusaurus.config.ts via `docs.sidebarItemsGenerator`. It runs
// after the default autogeneration, so it only post-processes the tree the
// default generator builds from the vault's directory structure.
//
// Docusaurus already labels individual notes from their H1. The gap is category
// (folder) labels, which otherwise come out as the raw lowercase dirname. Every
// folder in the vault has an index.md, so a section is labelled from that index
// note's H1 — to rename a section, retitle its index note. The humanize step is
// only a fallback for a folder that somehow lacks an index note.

/** Turn a folder name like `migration-guides` into `Migration Guides`. */
function humanize(name) {
	return name
		.split(/[-_\s]+/)
		.filter(Boolean)
		.map((word) => word.charAt(0).toUpperCase() + word.slice(1))
		.join(" ");
}

export default async function obsidianSidebarItems({ defaultSidebarItemsGenerator, ...args }) {
	const items = await defaultSidebarItemsGenerator(args);
	const docById = new Map(args.docs.map((doc) => [doc.id, doc]));

	function labelCategories(list) {
		return list.map((item) => {
			if (item.type !== "category") return item;

			// A category links to its index note (e.g. concepts/index.md); use that
			// note's title as the section label, falling back to the folder name.
			const indexId = item.link?.type === "doc" ? item.link.id : undefined;
			const label = (indexId && docById.get(indexId)?.title) || humanize(item.label);

			return { ...item, label, items: labelCategories(item.items) };
		});
	}

	return labelCategories(items);
}
