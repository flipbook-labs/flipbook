local CommonTypes = require("@root/Common/types")
local Storyteller = require("@pkg/Storyteller")
local useThemeName = require("@root/Common/useThemeName")

type Pluginlike = CommonTypes.Pluginlike
type LoadedStorybook = Storyteller.LoadedStorybook
type ThemeName = useThemeName.ThemeName

export type ExtraStoryProps = {
	theme: ThemeName,
	locale: string,

	-- TODO: Make these reequired in the future. Only reason they're not is
	-- because we'll need to massage the types in StoryPreview to clear the nil
	-- value. And I didn't want to do that yet
	plugin: Pluginlike?,
	widget: GuiBase2d?,
}

export type StorySnapshot = {
	id: string,
	name: string,
	summary: string?,
}

export type StoryModuleSnapshot = {
	name: string,
	source: ModuleScript,
	stories: { StorySnapshot },
	problem: string?,
}

export type StoryModuleTarget = {
	storyModule: ModuleScript,
	storybook: LoadedStorybook,
}

export type StoryModuleSnapshots = {
	[ModuleScript]: {
		[ModuleScript]: StoryModuleSnapshot,
	},
}

return nil
