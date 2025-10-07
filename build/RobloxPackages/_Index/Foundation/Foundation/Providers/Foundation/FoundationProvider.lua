local Providers = script.Parent.Parent
local Foundation = Providers.Parent
local Packages = Foundation.Parent
local React = require(Packages.React)

local PreferencesProvider = require(Providers.Preferences.PreferencesProvider)
local StyleProvider = require(Providers.Style.StyleProvider)
local CursorProvider = require(Providers.Cursor)
local OverlayProvider = require(Providers.Overlay)

type StyleProps = StyleProvider.StyleProviderProps
type Preferences = PreferencesProvider.PreferencesProps

export type FoundationProviderProps = StyleProps & {
	-- Plugins must provide overlay since they can't use the default PlayerGui
	overlayGui: GuiBase2d?,
	preferences: Preferences?,
}

local function FoundationProvider(props: FoundationProviderProps)
	-- TODO: not any, children types acting weird
	local preferences: any = if props.preferences then props.preferences else {}

	return React.createElement(PreferencesProvider, preferences, {
		StyleProvider = React.createElement(StyleProvider, {
			theme = props.theme,
			device = props.device,
			derives = props.derives,
			scale = preferences.scale,
		}, {
			OverlayProvider = React.createElement(OverlayProvider, { gui = props.overlayGui }, {
				CursorProvider = React.createElement(CursorProvider, nil, props.children),
			}),
		}),
	})
end

return FoundationProvider
