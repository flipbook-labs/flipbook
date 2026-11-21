local Foundation = require("@rbxpkg/Foundation")

local CommonTypes = require("@root/Common/types")
local useColorMode = require("@root/Common/useColorMode")

type ColorMode = useColorMode.ColorMode
type Pluginlike = CommonTypes.Pluginlike

export type ExtraStoryProps = {
	colorMode: ColorMode,
	themeName: Foundation.ThemeName,
	-- Deprecated. Use `colorMode` instead.
	theme: ColorMode,
	locale: string,

	-- TODO: Make these reequired in the future. Only reason they're not is
	-- because we'll need to massage the types in StoryPreview to clear the nil
	-- value. And I didn't want to do that yet
	plugin: Pluginlike?,
	widget: GuiBase2d?,
}

return nil
