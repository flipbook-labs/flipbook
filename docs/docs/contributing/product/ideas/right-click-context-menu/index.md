# Right-click context menu

Right-click context menu for items in the sidebar

1. Reload (interim solution to ModuleLoader just working properly)
2. View source
3. Choose renderer (Studio Mode)
4. Pin/Unpin

How renderer choice can work:

1. Click "Choose renderer" option
2. Open dialog with our supported renderers as tiles (React, Fusion, Roact, Vanilla)
3. User clicks one of the tiles
4. Tell user to select the package(s) in the explorer to use for rendering
5. Update the storybook/story source with the packages to use
