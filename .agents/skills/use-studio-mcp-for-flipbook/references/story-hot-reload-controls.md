# Verify story controls after a hot reload

Use this scenario to verify that controls stay connected when Studio reloads an open story module.

1. Use `listStorybooks` and `listStories` to discover a story with a string control.
2. Open the story and wait until `getCurrentStory` reports `isMounted = true`.
3. Use `setControls` to set a distinctive value, then confirm it through `getControls` and the mounted Flipbook UI.
4. Make a harmless source edit to the open story module so Studio reloads it.
5. Wait for the story to mount again and use `setControls` with a second distinctive value.
6. Confirm the second value appears in both `getControls` and the mounted control and preview UI without reopening the story.

Record the storybook and story paths, values used, and any console errors with the result.
