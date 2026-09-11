local Charm = require("@pkg/Charm")

local navigationEnums = require("@root/Navigation/enums")

type Screen = navigationEnums.Screen

export type NavigationStore = {
	getNavigationStack: () -> { Screen },
	getCurrentScreen: () -> Screen,
	navigateTo: (newScreen: Screen) -> (),
	goBack: () -> (),
	canGoBack: () -> boolean,
	getBreadcrumbs: () -> { Screen },
}

local function createNavigationStore(): NavigationStore
	local getNavigationStack, setNavigationStack = Charm.signal({ navigationEnums.Screen.Home } :: { Screen })

	local getCurrentScreenSignal = Charm.computed(function()
		local stack = getNavigationStack()
		return stack[#stack]
	end)

	local function getCurrentScreen(): Screen
		return getCurrentScreenSignal() :: Screen
	end

	local function navigateTo(newScreen: Screen)
		setNavigationStack(function(prev)
			local new = table.clone(prev)
			table.insert(new, newScreen)
			return new
		end)
	end

	local function canGoBack(): boolean
		return #getNavigationStack() > 1
	end

	local function goBack()
		if canGoBack() then
			setNavigationStack(function(prev)
				local new = table.clone(prev)
				table.remove(new)
				return new
			end)
		end
	end

	local function getBreadcrumbs(): { Screen }
		return getNavigationStack()
	end

	return {
		getNavigationStack = getNavigationStack,
		getCurrentScreen = getCurrentScreen,
		navigateTo = navigateTo,
		goBack = goBack,
		canGoBack = canGoBack,
		getBreadcrumbs = getBreadcrumbs,
	}
end

return createNavigationStore
