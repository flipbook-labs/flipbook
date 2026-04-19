---
notion-id: 27695b79-12f8-809a-82b1-e420cd547c43
tags: [idea]
aliases: [Right-click-context-menu]
linter-yaml-title-alias: Right-click-context-menu
---

# Right-click-context-menu

Right-click context menu for items in the sidebar

1. Reload (interim solution to ModuleLoader just working properly)
2. View source
3. Choose renderer (Studio Mode)
4. Pin/Unpin

How renderer choice can work:

5. Click "Choose renderer" option
6. Open dialog with our supported renderers as tiles (React, Fusion, Roact, Vanilla)
7. User clicks one of the tiles
8. Tell user to select the package(s) in the explorer to use for rendering
9. Update the storybook/story source with the packages to use
