local React = require("@pkg/React")

local navigationEnums = require("@root/Navigation/enums")

local useCallback = React.useCallback
local useContext = React.useContext
local useMemo = React.useMemo
local useState = React.useState

type Screen = navigationEnums.Screen

export type NavigationContext = {
	navigateTo: (newScreen: Screen) -> (),
	goBack: () -> (),
	getBreadcrumbs: () -> { string },
	currentScreen: Screen,
}

local Context = React.createContext({} :: NavigationContext)

export type Props = {
	defaultScreen: Screen,
	children: React.Node?,
}

local function Provider(props: Props)
	local stack: { Screen }, setStack = useState({ props.defaultScreen })

	local navigateTo = useCallback(function(newScreen: Screen)
		setStack(function(prev)
			local new = table.clone(prev)
			table.insert(new, newScreen)
			return new
		end)
	end, {})

	local currentScreen = useMemo(function()
		return stack[#stack]
	end, { stack })

	local canGoBack = useMemo(function()
		return #stack > 1
	end, { stack })

	local goBack = useCallback(function()
		if canGoBack then
			setStack(function(prev)
				local new = table.clone(prev)
				table.remove(new)
				return new
			end)
		end
	end, { canGoBack })

	return React.createElement(Context.Provider, {
		value = {
			navigateTo = navigateTo,
			goBack = goBack,
			breadcrumbs = stack,
			currentScreen = currentScreen,
		},
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
