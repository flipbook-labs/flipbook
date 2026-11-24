local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local AppMode = require("@root/Enums/AppMode")
local CommonTypes = require("@root/Common/types")
local ContextStack = require("@root/Common/ContextStack")
local FlipbookStoreContext = require("@root/FlipbookStore/FlipbookStoreContext")
local PluginStore = require("@root/Plugin/PluginStore")
local createFlipbookStore = require("@root/FlipbookStore/createFlipbookStore")
local useThemeName = require("@root/Common/useThemeName")

local useEffect = React.useEffect
local useMemo = React.useMemo

type AppMode = AppMode.AppMode
type FlipbookStore = createFlipbookStore.FlipbookStore
type Pluginlike = CommonTypes.Pluginlike

export type Props = {
	plugin: Pluginlike,
	theme: Foundation.Theme?,
	overlayGui: GuiBase2d?,
	mode: AppMode?,
	store: FlipbookStore?,
	children: React.Node?,
}

local function ContextProviders(props: Props)
	local themeName: Foundation.Theme = useThemeName()
	local store = useMemo(function()
		return props.store
			or createFlipbookStore({
				mode = props.mode or AppMode.PluginWidget,
				plugin = props.plugin,
			})
	end, { props.mode, props.plugin, props.store } :: { unknown })

	useEffect(function()
		PluginStore.get().setPlugin(props.plugin)
	end, { props.plugin })

	return React.createElement(ContextStack, {
		providers = {
			React.createElement(Foundation.FoundationProvider, {
				theme = props.theme or themeName,
				overlayGui = props.overlayGui,
			}),
			React.createElement(FlipbookStoreContext.Provider, {
				store = store,
			}),
			React.createElement(Storyteller.StorytellerProvider),
		},
	}, props.children)
end

return ContextProviders
