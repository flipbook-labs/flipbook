local CommonTypes = require("@root/Common/types")
local useThemeName = require("@root/Common/useThemeName")

type Pluginlike = CommonTypes.Pluginlike
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

return nil
