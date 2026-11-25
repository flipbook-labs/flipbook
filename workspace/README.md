# Workspace

This folder contains all of the individual packages that make up Flipbook. Each one is a member of the Lute package workspace that the root [`pkg.luau`](../pkg.luau) defines.

## Adding new members

```luau
cp -R workspace/template workspace/new-package
```

Perform a find-and-replace in `workspace/new-package` for `template` and `Template`, including its `pkg.luau`. Replace the former with the hyphenated name `new-package`, and the latter with the human-readable `NewPackage`.

Add the member to the root [`pkg.luau`](../pkg.luau). Put it in `dependencies` if it ships with the plugin, or in `dev_dependencies` if it's only for development. Production builds prune development members.

Update [`workspace/default.project.json`](default.project.json) to include the new package

Run `lute run install` and `lute run build`
