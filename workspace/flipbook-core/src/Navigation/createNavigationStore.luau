local Charm = require("@pkg/Charm")
local Telemetry = require(script.Parent.Parent.Parent["flipbook-telemetry"])

local navigationEnums = require("@root/Navigation/enums")

type Screen = navigationEnums.Screen
type TelemetryClient = Telemetry.TelemetryClient

export type NavigationStore = {
	getNavigationStack: () -> { Screen },
	getCurrentScreen: () -> Screen,
	navigateTo: (newScreen: Screen) -> (),
	goBack: () -> (),
	canGoBack: () -> boolean,
	getBreadcrumbs: () -> { Screen },
}

local function createNavigationStore(telemetry: TelemetryClient?): NavigationStore
	local getNavigationStack, setNavigationStack = Charm.signal({ navigationEnums.Screen.Home } :: { Screen })

	local getCurrentScreenSignal = Charm.computed(function()
		local stack = getNavigationStack()
		return stack[#stack]
	end)

	local function getCurrentScreen(): Screen
		return getCurrentScreenSignal() :: Screen
	end

	local function reportPageChanged(screen: Screen)
		if telemetry then
			telemetry.capture({
				eventName = "PageChanged",
				properties = {
					page = screen,
				},
			})
		end
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
