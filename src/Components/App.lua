local flipbook = script:FindFirstAncestor("flipbook")

local ModuleLoader = require(flipbook.Packages.ModuleLoader)
local Roact = require(flipbook.Packages.Roact)
local hook = require(flipbook.hook)
local useStorybooks = require(flipbook.Hooks.useStorybooks)
local useTheme = require(flipbook.Hooks.useTheme)
local PluginContext = require(flipbook.Plugin.PluginContext)
local Canvas = require(script.Parent.Canvas)
local Sidebar = require(script.Parent.Sidebar)

local loader = ModuleLoader.new()

export type Props = {
	plugin: Plugin,
}

local function App(props: Props, hooks: any)
	local theme = useTheme(hooks)
	local storybooks = useStorybooks(hooks, game, loader)
	local story, setStory = hooks.useState(nil)
	local storybook, selectStorybook = hooks.useState(nil)

	local selectStory = hooks.useCallback(function(newStory: ModuleScript)
		setStory(function(prevStory: ModuleScript)
			return if prevStory ~= newStory then newStory else nil
		end)
	end, { setStory })

	return Roact.createElement(PluginContext.Provider, {
		plugin = props.plugin,
	}, {
		Roact.createElement("Frame", {
			BackgroundColor3 = theme.background,
			Size = UDim2.fromScale(1, 1),
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			Sidebar = Roact.createElement(Sidebar, {
				layoutOrder = 1,
				selectStory = selectStory,
				selectStorybook = selectStorybook,
				storybooks = storybooks,
			}),

			Canvas = Roact.createElement(Canvas, {
				layoutOrder = 2,
				loader = loader,
				story = story,
				storybook = storybook,
			}),
		}),
	})
end

return hook(App)
