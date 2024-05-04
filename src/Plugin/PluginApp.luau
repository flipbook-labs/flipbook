local ContextStack = require("@root/Common/ContextStack")
local PluginContext = require("@root/Plugin/PluginContext")
local React = require("@pkg/React")
local ResizablePanel = require("@root/Panels/ResizablePanel")
local SettingsContext = require("@root/UserSettings/SettingsContext")
local Sidebar = require("@root/Panels/Sidebar")
local StoryCanvas = require("@root/Storybook/StoryCanvas")
local constants = require("@root/constants")
local useStorybooks = require("@root/Storybook/useStorybooks")
local useTheme = require("@root/Common/useTheme")

export type Props = {
	plugin: Plugin,
	loader: any,
}

local function App(props: Props)
	local theme = useTheme()
	local storybooks = useStorybooks(game, props.loader)
	local story, setStory = React.useState(nil)
	local storybook, selectStorybook = React.useState(nil)
	local sidebarWidth, setSidebarWidth = React.useState(constants.SIDEBAR_INITIAL_WIDTH)

	local selectStory = React.useCallback(function(newStory: ModuleScript)
		setStory(function(prevStory: ModuleScript)
			return if prevStory ~= newStory then newStory else nil
		end)
	end, { setStory })

	local onSidebarResized = React.useCallback(function(newSize: Vector2)
		setSidebarWidth(newSize.X)
	end, {})

	return React.createElement(ContextStack, {
		providers = {
			React.createElement(PluginContext.Provider, {
				plugin = props.plugin,
			}),
			React.createElement(SettingsContext.Provider),
		},
	}, {
		Background = React.createElement("Frame", {
			BackgroundColor3 = theme.background,
			Size = UDim2.fromScale(1, 1),
		}, {
			Layout = React.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			SidebarWrapper = React.createElement(ResizablePanel, {
				layoutOrder = 1,
				initialSize = UDim2.new(0, constants.SIDEBAR_INITIAL_WIDTH, 1, 0),
				dragHandles = { "Right" },
				minSize = Vector2.new(constants.SIDEBAR_MIN_WIDTH, 0),
				maxSize = Vector2.new(constants.SIDEBAR_MAX_WIDTH, math.huge),
				onResize = onSidebarResized,
			}, {
				Sidebar = React.createElement(Sidebar, {
					selectStory = selectStory,
					selectStorybook = selectStorybook,
					storybooks = storybooks,
				}),
			}),

			MainWrapper = React.createElement("Frame", {
				LayoutOrder = 2,
				Size = UDim2.fromScale(1, 1) - UDim2.fromOffset(sidebarWidth, 0),
			}, {
				StoryCanvas = React.createElement(StoryCanvas, {
					loader = props.loader,
					story = story,
					storybook = storybook,
				}),
			}),
		}),
	})
end

return App
