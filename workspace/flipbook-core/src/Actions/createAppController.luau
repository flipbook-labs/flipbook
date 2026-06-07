--[[
	The seam between actions and app capabilities.

	`toggleWidget` is backed directly by the dock widget, so it works at bootstrap
	even before the React app mounts. Everything else (navigation, story
	selection, listing) lives in React-local state, so it is provided by the app
	via `register` when `FlipbookApp` mounts and cleared on unmount.

	Calls that need the app while it is unmounted return a failed `ActionResult`
	rather than erroring, so the agent door always gets a well-formed envelope.
]]

local types = require("@root/Actions/types")

local function createAppController(widget: DockWidgetPluginGui): types.AppController
	local impl: types.AppControllerImpl? = nil

	local function notMounted(): types.ActionResult
		return { ok = false, error = "Flipbook app is not mounted" }
	end

	local controller: types.AppController = {
		toggleWidget = function(enabled: boolean?)
			if enabled == nil then
				widget.Enabled = not widget.Enabled
			else
				widget.Enabled = enabled
			end
		end,

		navigateTo = function(screen: string): types.ActionResult
			if not impl then
				return notMounted()
			end
			impl.navigateTo(screen)
			return { ok = true }
		end,

		selectStory = function(path: string): types.ActionResult
			if not impl then
				return notMounted()
			end
			return impl.selectStory(path)
		end,

		listStories = function(): { types.StoryInfo }
			if not impl then
				return {}
			end
			return impl.listStories()
		end,

		getState = function(): types.AppState
			local appState = if impl then impl.getState() else nil
			return {
				widgetOpen = widget.Enabled,
				screen = if appState then appState.screen else "Home",
				selectedStory = if appState then appState.selectedStory else nil,
			}
		end,

		register = function(newImpl: types.AppControllerImpl): () -> ()
			impl = newImpl
			return function()
				if impl == newImpl then
					impl = nil
				end
			end
		end,
	}

	return controller
end

return createAppController
