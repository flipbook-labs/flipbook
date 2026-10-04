# Documentation code samples

Docs reference real, type-checked Luau from
[`workspace/code-samples/src`](../../workspace/code-samples) instead of pasting
copies that rot. Authors write a `code-sample` fenced block whose body is a
repo-root-relative path; both the Obsidian vault and the Docusaurus site expand
it to the actual file contents.

## Authoring

````md
```code-sample
workspace/code-samples/src/React/ReactButton.luau
```
````

Pull a slice instead of the whole file with a line-range fragment:

- `…/ReactButton.luau#L4-L13` — lines 4 through 13
- `…/ReactButton.luau#L7` — single line 7

If a block can't be resolved, both surfaces surface a visible error rather than
failing silently or breaking the build.

## How it works

One shared extractor, two thin adapters, so the surfaces can't drift:

| Piece | Path | Role |
| --- | --- | --- |
| Extractor | `extract.mjs` | Pure ESM, zero deps. Parses the spec, reads the file, slices the range, dedents, maps `.luau -> lua`. The single source of truth. |
| Docusaurus adapter | `../site/src/remark/code-sample.mjs` | Remark plugin (wired in `docusaurus.config.ts`) that rewrites `code-sample` code nodes into highlighted `lua` blocks at build time. |
| Obsidian adapter | `obsidian/` | Reading-view plugin that reads the out-of-vault source via Node `fs` and renders it through Obsidian's own renderer. |

## The Obsidian plugin

The plugin source lives in [`obsidian/`](obsidian). `lute run install` bundles it
with esbuild into the vault's gitignored
`docs/obsidian-vault/.obsidian/plugins/code-sample/`, so nothing built is
committed. After installing, enable **Code Sample** in Obsidian's community
plugin settings once.

To rebuild it by hand:

```sh
npx --yes esbuild@0.21.5 docs/code-samples/obsidian/main.ts \
  --bundle --format=cjs --platform=node --target=es2020 --external:obsidian \
  --outfile=docs/obsidian-vault/.obsidian/plugins/code-sample/main.js
```

## Tests

```sh
node --test docs/code-samples/extract.test.mjs
```
