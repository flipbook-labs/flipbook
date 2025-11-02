# Workspace

This folder contains all of the individual packages that make up Flipbook.

## Adding new members

```luau
cp -R workspace/template workspace/new-package
```

Perform a find-and-replace in `workspace/new-package` for `template` and `Template`. Replace the former with the hyphenated name `new-package`, and the latter with the human-readable `NewPackage`.

Update [`workspace/default.project.json`](default.project.json) to include the new package

Run `lute scripts/install.luau` and `lute scripts/build.luau`

Some packages are not included with production builds. If your package also should not be included, update `PROD_CONFIG` in `project.luau` to omit it.
