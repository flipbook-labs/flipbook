---
aliases: [October Roblox internal notes]
linter-yaml-title-alias: October Roblox internal notes
notion-id: 2db95b79-12f8-8173-b63d-defffbacaeb7
---

# October Roblox Internal Notes

Attempting to `require()` .global files is what's causing ModuleLoader to fail with "Cannot require a non-RobloxScript module from a RobloxScript"

The bulk of the issues with the rest of the storybooks is that they don't call UIBlox.init themselves, they rely on other storybooks having called it

* Hoisting the ModuleLoader defined in useStorybooks up to the global scope fixes the issue for most storybooks
* The UIBlox issue is still weird because even for Songbird and AppMusicPlayer if I setup UIBlox myself it still doesn't work

Other local changes I've made:

* Trying to use xpcall instead of pcall is kind of helpful
* Also I don't think we need the LuauPolyfill dependency. We shouldn't need to `error(Error.new(msg))`, I don't know why we have that

TODO: Set Flipbook's name for the PluginGui instance it generates so I can find it in the DataModel

Some storybooks don’t include a `storyRoots` or `storyRoot` key. Assume that if undefined that `storyRoots = { script.Parent }` and set that when loading a storybook

Something is wrong with MusicTestingUtils that’s somehow implicitly importing Jest when used. This is breaking Music storybooks.

* This is getting fixed by a PR I have up for review already

Where you left off in StudioPlugins is that Flipbook can be opened but once closed you can’t reopen it from the action in the command panel.

Issues I’ve noticed:

1. Controls
    1. For PersistentMusicPlayer, the songName dropdown isn’t rendering any text for the options. I can still choose between the various options, there’s just no labels
    2. Popovers aren’t working, we may not be passing down the host

I want to be able to point FlipbookInternal's rotriever.toml directly to my local copy of Flipbook

* I need to include rotriever.toml in upstream Flipbook for that to work, so how should we handle versions? Could I maybe leave a default `0.1.0` version that gets overwritten by the sync job? I just need something that won't result in merge conflicts since that can brick the workflow
