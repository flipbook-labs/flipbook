// Docusaurus remark plugin that resolves Obsidian-flavored Markdown from the
// vault (docs/obsidian-vault) as Docusaurus reads it: wikilinks, image embeds,
// note transclusions, and callouts. Wired into docusaurus.config.ts via
// `beforeDefaultRemarkPlugins` so the output (links, admonition directives) is
// then processed by Docusaurus's own defaults.
//
// It runs per file. Transclusions are the one cross-file step: they read the
// target out of the vault, slice the requested section, and splice it in before
// the wikilink/callout passes run over the merged tree.

import { unified } from "unified";
import remarkParse from "remark-parse";
import remarkFrontmatter from "remark-frontmatter";
import remarkGfm from "remark-gfm";
import { visit, SKIP } from "unist-util-visit";
import { toString as mdToString } from "mdast-util-to-string";

import { readFileSync, readdirSync } from "node:fs";
import { join, relative } from "node:path";
import { posix } from "node:path";

// Vault files that should never be treated as content.
const IGNORED_DIRS = new Set([".obsidian"]);
const IGNORED_EXTENSIONS = new Set([".base"]); // Obsidian Bases (database views)

// Obsidian callout type -> Docusaurus admonition type.
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

// A standalone processor for parsing transclusion targets out of the vault.
const targetParser = unified()
	.use(remarkParse)
	.use(remarkFrontmatter)
	.use(remarkGfm);

const LINK_PATTERN = /!\[\[([^\]]+?)\]\]|\[\[([^\]]+?)\]\]/g;

function extOf(rel) {
	const i = rel.lastIndexOf(".");
	return i === -1 ? "" : rel.slice(i).toLowerCase();
}

/** Normalize a path or wikilink target for case/space-insensitive matching. */
function normalizeKey(rel) {
	return rel
		.toLowerCase()
		.replace(/\.md$/, "")
		.split("/")
		.map((seg) => seg.trim().replace(/\s+/g, "-"))
		.join("/");
}

function assetKey(rel) {
	return rel
		.toLowerCase()
		.split("/")
		.map((seg) => seg.trim().replace(/\s+/g, "-"))
		.join("/");
}

/** GitHub-style heading slug, matching Docusaurus anchors closely enough. */
function slugAnchor(text) {
	return text
		.toLowerCase()
		.trim()
		.replace(/[^\w\s-]/g, "")
		.replace(/\s+/g, "-")
		.replace(/-+/g, "-");
}

function splitAlias(inner) {
	const i = inner.indexOf("|");
	if (i === -1) return [inner.trim(), null];
	return [inner.slice(0, i).trim(), inner.slice(i + 1).trim()];
}

/** Recursively list vault-relative (posix) paths, skipping ignored dirs. */
function walk(dir, prefix = "") {
	const out = [];
	for (const entry of readdirSync(dir, { withFileTypes: true })) {
		if (entry.isDirectory()) {
			if (IGNORED_DIRS.has(entry.name)) continue;
			out.push(...walk(join(dir, entry.name), posix.join(prefix, entry.name)));
		} else {
			out.push(posix.join(prefix, entry.name));
		}
	}
	return out;
}

/** Build lookup tables for resolving notes and assets within the vault. */
function buildIndex(vault) {
	const all = walk(vault);
	const mdByPath = new Map();
	const mdByName = new Map();
	const assetByPath = new Map();
	const assetByName = new Map();

	for (const rel of all) {
		const ext = extOf(rel);
		if (ext === ".md") {
			mdByPath.set(normalizeKey(rel), rel);
			const name = normalizeKey(rel).split("/").pop();
			if (!mdByName.has(name)) mdByName.set(name, rel);
		} else if (!IGNORED_EXTENSIONS.has(ext)) {
			const key = assetKey(rel);
			assetByPath.set(key, rel);
			const name = key.split("/").pop();
			if (!assetByName.has(name)) assetByName.set(name, rel);
		}
	}
	return { mdByPath, mdByName, assetByPath, assetByName };
}

/** Extract a heading's section (inclusive) from a parsed tree, or all of it. */
function extractSection(tree, section) {
	const children = tree.children.filter(
		(n) => n.type !== "yaml" && n.type !== "toml",
	);
	if (!section) return children;

	const wanted = slugAnchor(section);
	const startIndex = children.findIndex(
		(n) => n.type === "heading" && slugAnchor(mdToString(n)) === wanted,
	);
	if (startIndex === -1) return null;

	const depth = children[startIndex].depth;
	const result = [children[startIndex]];
	for (let i = startIndex + 1; i < children.length; i++) {
		const n = children[i];
		if (n.type === "heading" && n.depth <= depth) break;
		result.push(n);
	}
	return result;
}

/** If a node is a standalone `![[...]]` paragraph, return its parsed spec. */
function matchTransclusion(node) {
	if (node.type !== "paragraph" || node.children.length !== 1) return null;
	const child = node.children[0];
	if (child.type !== "text") return null;
	const m = child.value.trim().match(/^!\[\[([^\]]+)\]\]$/);
	if (!m) return null;
	let inner = m[1];
	const pipe = inner.indexOf("|");
	if (pipe !== -1) inner = inner.slice(0, pipe);
	const [target, ...rest] = inner.split("#");
	return { target: target.trim(), section: rest.join("#").trim() || null };
}

/** Convert Obsidian `> [!type] title` callouts to Docusaurus admonitions. */
function convertCallouts(tree) {
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

		const directive = {
			type: "containerDirective",
			name,
			attributes: {},
			children,
		};
		parent.children.splice(index, 1, directive);
		return [SKIP];
	});
}

export default function remarkObsidian(options = {}) {
	const vault = options.vault;
	if (!vault) throw new Error("remarkObsidian: the `vault` option is required");

	const { mdByPath, mdByName, assetByPath, assetByName } = buildIndex(vault);
	const warned = new Set();
	function warn(message) {
		if (warned.has(message)) return;
		warned.add(message);
		console.warn(`[remark-obsidian] ${message}`);
	}

	function resolveNote(target) {
		const key = normalizeKey(target);
		if (mdByPath.has(key)) return mdByPath.get(key);
		return mdByName.get(key.split("/").pop()) ?? null;
	}

	function resolveAsset(target) {
		const key = assetKey(target);
		if (assetByPath.has(key)) return assetByPath.get(key);
		return assetByName.get(key.split("/").pop()) ?? null;
	}

	/** Relative link from one vault-rel file to another (the vault is the tree). */
	function relLink(fromRel, toRel) {
		let r = posix.relative(posix.dirname(fromRel), toRel);
		if (!r.startsWith(".")) r = "./" + r;
		return r;
	}

	/** Recursively inline note transclusions throughout a node's children. */
	function expandTransclusions(node, stack) {
		if (!node.children) return;
		const next = [];
		for (const child of node.children) {
			const tx = matchTransclusion(child);
			const targetRel = tx ? resolveNote(tx.target) : null;
			if (tx && targetRel) {
				const key =
					normalizeKey(targetRel) +
					(tx.section ? "#" + slugAnchor(tx.section) : "");
				if (stack.has(key)) {
					warn(
						`circular transclusion skipped: ![[${tx.target}${tx.section ? "#" + tx.section : ""}]]`,
					);
					continue;
				}
				const targetTree = targetParser.parse(
					readFileSync(join(vault, targetRel), "utf8"),
				);
				const section = extractSection(targetTree, tx.section);
				if (section === null) {
					warn(
						`transclusion section not found: ![[${tx.target}#${tx.section}]]`,
					);
					next.push(child);
					continue;
				}
				const wrapper = { type: "root", children: section };
				expandTransclusions(wrapper, new Set([...stack, key]));
				next.push(...wrapper.children);
			} else {
				expandTransclusions(child, stack);
				next.push(child);
			}
		}
		node.children = next;
	}

	function makeLink(inner, fromRel) {
		const [targetPart, alias] = splitAlias(inner);
		const hash = targetPart.indexOf("#");
		const pathPart = hash === -1 ? targetPart : targetPart.slice(0, hash);
		const section = hash === -1 ? null : targetPart.slice(hash + 1);

		if (pathPart === "") {
			return {
				type: "link",
				url: "#" + slugAnchor(section ?? ""),
				children: [{ type: "text", value: alias ?? section ?? "" }],
			};
		}

		const targetRel = resolveNote(pathPart);
		if (!targetRel) {
			warn(`unresolved wikilink in ${fromRel}: [[${inner}]]`);
			return { type: "text", value: alias ?? pathPart };
		}
		const url =
			relLink(fromRel, targetRel) + (section ? "#" + slugAnchor(section) : "");
		const text = alias ?? section ?? posix.basename(targetRel, ".md");
		return { type: "link", url, children: [{ type: "text", value: text }] };
	}

	function makeEmbed(inner, fromRel) {
		const [targetPart] = splitAlias(inner); // a trailing |size is ignored for now
		const assetRel = resolveAsset(targetPart);
		if (assetRel) {
			return {
				type: "image",
				url: relLink(fromRel, assetRel),
				alt: posix.basename(assetRel),
			};
		}
		if (resolveNote(targetPart.split("#")[0])) return makeLink(inner, fromRel);
		warn(`unresolved embed in ${fromRel}: ![[${inner}]]`);
		return { type: "text", value: `![[${inner}]]` };
	}

	/** Replace `[[...]]` / `![[...]]` inside text nodes with link/image nodes. */
	function convertWikilinks(tree, fromRel) {
		visit(tree, "text", (node, index, parent) => {
			if (index === null || !parent || !node.value.includes("[[")) return;

			LINK_PATTERN.lastIndex = 0;
			const replacement = [];
			let last = 0;
			let match;
			while ((match = LINK_PATTERN.exec(node.value)) !== null) {
				if (match.index > last) {
					replacement.push({
						type: "text",
						value: node.value.slice(last, match.index),
					});
				}
				replacement.push(
					match[1] !== undefined
						? makeEmbed(match[1], fromRel)
						: makeLink(match[2], fromRel),
				);
				last = LINK_PATTERN.lastIndex;
			}
			if (replacement.length === 0) return;
			if (last < node.value.length)
				replacement.push({ type: "text", value: node.value.slice(last) });

			parent.children.splice(index, 1, ...replacement);
			return [SKIP, index + replacement.length];
		});
	}

	/** Some migrated images have a wikilink embedded in their URL; recover it. */
	function fixImageUrls(tree, fromRel) {
		visit(tree, "image", (node) => {
			const m = node.url && node.url.match(/!?\[\[([^\]]+?)\]\]/);
			if (!m) return;
			const assetRel = resolveAsset(splitAlias(m[1])[0]);
			node.url = assetRel ? relLink(fromRel, assetRel) : m[1];
		});
	}

	return function transformer(tree, file) {
		const fromRel = relative(vault, file.path).split(/[\\/]/g).join("/");

		expandTransclusions(tree, new Set([normalizeKey(fromRel)]));
		fixImageUrls(tree, fromRel);
		convertWikilinks(tree, fromRel);
		convertCallouts(tree);
	};
}
