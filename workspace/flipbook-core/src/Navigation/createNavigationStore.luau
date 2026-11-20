local Charm = require("@pkg/Charm")

local fireEventAsync = require("@root/Telemetry/fireEventAsync")
local navigationEnums = require("@root/Navigation/enums")

type Screen = navigationEnums.Screen

export type NavigationStore = {
	getNavigationStack: () -> { Screen },
	getCurrentScreen: () -> Screen,
	navigateTo: (newScreen: Screen) -> (),
	goBack: () -> (),
	canGoBack: () -> boolean,
	getBreadcrumbs: () -> { Screen },
	reportCurrentScreen: () -> (),
}

local function createNavigationStore(): NavigationStore
	local getNavigationStack, setNavigationStack = Charm.signal<<{ Screen }>>({ navigationEnums.Screen.Home })

	local getCurrentScreen = Charm.computed<<Screen>>(function()
		local stack = getNavigationStack()
		return stack[#stack]
	end)

	local function reportPageChanged(screen: Screen)
		task.spawn(function()
			fireEventAsync({
				eventName = "PageChanged",
				properties = {
					page = screen,
				},
			})
		end)
	end

	local function navigateTo(newScreen: Screen)
		setNavigationStack(function(previousStack)
			local newStack = table.clone(previousStack)
			table.insert(newStack, newScreen)
			return newStack
		end)
		reportPageChanged(newScreen)
	end

	local function canGoBack(): boolean
		return #getNavigationStack() > 1
	end

	local function goBack()
		if not canGoBack() then
			return
		end

		setNavigationStack(function(previousStack)
			local newStack = table.clone(previousStack)
			table.remove(newStack)
			return newStack
		end)
		reportPageChanged(getCurrentScreen())
	end

	local function getBreadcrumbs(): { Screen }
		return getNavigationStack()
	end

	local function reportCurrentScreen()
		reportPageChanged(getCurrentScreen())
	end

	return {
		getNavigationStack = getNavigationStack,
		getCurrentScreen = getCurrentScreen,
		navigateTo = navigateTo,
		goBack = goBack,
		canGoBack = canGoBack,
		getBreadcrumbs = getBreadcrumbs,
		reportCurrentScreen = reportCurrentScreen,
	}
end

return createNavigationStore
