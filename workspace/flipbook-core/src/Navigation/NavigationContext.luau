local React = require("@pkg/React")
local ReactCharm = require("@pkg/ReactCharm")

local AppStore = require("@root/AppStore")
local fireEventAsync = require("@root/Telemetry/fireEventAsync")
local navigationEnums = require("@root/Navigation/enums")
local usePrevious = require("@root/Common/usePrevious")

local useContext = React.useContext
local useMemo = React.useMemo
local useEffect = React.useEffect
local useSignalState = ReactCharm.useSignalState

type Screen = navigationEnums.Screen

export type NavigationContext = {
	navigateTo: (newScreen: Screen) -> (),
	goBack: () -> (),
	getBreadcrumbs: () -> { Screen },
	canGoBack: () -> boolean,
	currentScreen: Screen,
}

local Context = React.createContext({} :: NavigationContext)

export type Props = {
	defaultScreen: Screen,
	children: React.Node?,
}

local function Provider(props: Props)
	local appStore = useSignalState(AppStore.get)
	local currentScreen = useSignalState(appStore.getCurrentScreen)
	local prevCurrentScreen = usePrevious(currentScreen)

	useEffect(function()
		if currentScreen ~= prevCurrentScreen then
			task.spawn(function()
				fireEventAsync({
					eventName = "PageChanged",
					properties = {
						page = currentScreen,
					},
				})
			end)
		end
	end, { currentScreen })

	local value = useMemo(function(): NavigationContext
		return {
			navigateTo = appStore.navigateTo,
			goBack = appStore.goBack,
			getBreadcrumbs = appStore.getBreadcrumbs,
			canGoBack = appStore.canGoBack,
			currentScreen = currentScreen :: Screen,
		}
	end, { appStore, currentScreen } :: { unknown })

	return React.createElement(Context.Provider, {
		value = value,
	}, props.children)
end

local function use(): NavigationContext
	return useContext(Context)
end

return {
	Context = Context,
	Provider = Provider,
	use = use,
}
