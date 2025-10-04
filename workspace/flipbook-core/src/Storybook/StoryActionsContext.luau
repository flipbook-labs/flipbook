local Selection = game:GetService("Selection")

local PluginStore = require("@root/Plugin/PluginStore")
local React = require("@pkg/React")
local ReactSignals = require("@rbxpkg/SignalsReact")
local useZoom = require("@root/Common/useZoom")

local e = React.createElement
local useRef = React.useRef
local useCallback = React.useCallback
local useContext = React.useContext
local useState = React.useState

local useSignalState = ReactSignals.useSignalState

export type StoryActionsContext = {
	isDisabled: boolean,
	isMountedInViewport: boolean,

	storyContainerRef: { current: GuiObject? }?,

	viewportPreview: () -> (),
	viewCode: () -> (),
	viewExplorer: () -> (),

	zoom: {
		value: number,
		zoomIn: () -> (),
		zoomOut: () -> (),
	},
}

local StoryActionsContext = React.createContext({} :: StoryActionsContext)

export type StoryActionsProviderProps = {
	children: React.ReactNode,
	story: ModuleScript?,
}

local function StoryActionsProvider(props: StoryActionsProviderProps)
	local pluginStore = useSignalState(PluginStore.get)
	local plugin = useSignalState(pluginStore.getPlugin)

	local isMountedInViewport, setIsMountedInViewport = useState(false)
	local storyContainerRef = useRef(nil :: GuiObject?)
	local zoom = useZoom(props.story)

	local viewportPreview = useCallback(function()
		setIsMountedInViewport(function(currentValue)
			return not currentValue
		end)
	end, {})

	local viewCode = useCallback(function()
		if props.story == nil then
			return
		end

		Selection:Set({ props.story })

		if plugin ~= nil then
			plugin:OpenScript(props.story)
		end
	end, { plugin, props.story } :: { any })

	local viewExplorer = useCallback(function()
		if storyContainerRef.current == nil then
			return
		end

		Selection:Set({ storyContainerRef.current:FindFirstAncestorWhichIsA("GuiObject") or storyContainerRef.current })
	end, {})

	return e(StoryActionsContext.Provider, {
		value = {
			isDisabled = props.story == nil,
			isMountedInViewport = isMountedInViewport,

			storyContainerRef = storyContainerRef,

			viewportPreview = viewportPreview,
			viewCode = viewCode,
			viewExplorer = viewExplorer,

			zoom = zoom,
		},
	}, props.children)
end

local function useStoryActions(): StoryActionsContext
	return useContext(StoryActionsContext)
end

return {
	Context = StoryActionsContext,
	Provider = StoryActionsProvider,
	useStoryActions = useStoryActions,
}
