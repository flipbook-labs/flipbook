local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local CommonTypes = require("@root/Common/types")
local types = require("@root/Storybook/types")
local useColorMode = require("@root/Common/useColorMode")
local useThemeName = require("@root/Common/useThemeName")

local useMemo = React.useMemo

type ColorMode = useColorMode.ColorMode
type ExtraStoryProps = types.ExtraStoryProps
type Pluginlike = CommonTypes.Pluginlike
type ThemeName = Foundation.ThemeName

export type Options = {
	plugin: Pluginlike?,
	widget: GuiBase2d?,
}

--[[
	Stories receive these props alongside their controls. The color mode and
	theme name come from the user's settings, so a story re-renders with new
	values when either setting changes. `theme` is the deprecated name for the
	color mode and stays equal to it for stories that still read it.
]]
local function useExtraStoryProps(options: Options): ExtraStoryProps
	local colorMode = useColorMode()
	local themeName = useThemeName()

	return useMemo(
		function(): ExtraStoryProps
			return {
				colorMode = colorMode :: ColorMode,
				themeName = themeName :: ThemeName,
				theme = colorMode :: ColorMode,
				locale = "en-us",
				plugin = options.plugin,
				widget = options.widget,
			}
		end,
		{
			colorMode,
			themeName,
			options.plugin,
			options.widget,
		} :: { unknown }
	)
end

return useExtraStoryProps
