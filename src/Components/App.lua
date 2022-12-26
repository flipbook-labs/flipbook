local flipbook = script:FindFirstAncestor("flipbook")

local ModuleLoader = require(flipbook.Packages.ModuleLoader)
local Sift = require(flipbook.Packages.Sift)
local Roact = require(flipbook.Packages.Roact)
local hook = require(flipbook.hook)
local useStorybooks = require(flipbook.Hooks.useStorybooks)
local useTheme = require(flipbook.Hooks.useTheme)
local PluginContext = require(flipbook.Plugin.PluginContext)
local ResizablePanel = require(script.Parent.ResizablePanel)
local Canvas = require(script.Parent.Canvas)
local Sidebar = require(script.Parent.Sidebar)

local loader = ModuleLoader.new()

local defaultProps = {
	initialsSidebarWidth = 260, -- px
	minSidebarWidth = 180, -- px
	maxSidebarWidth = 500, -- px
}

export type Props = typeof(defaultProps) & {
	plugin: Plugin,
}

type InternalProps = Props & typeof(defaultProps)

local function App(props: Props, hooks: any)
	props = Sift.Dictionary.merge(defaultProps, props)

	local theme = useTheme(hooks)
	local storybooks = useStorybooks(hooks, game, loader)
	local story, setStory = hooks.useState(nil)
	local storybook, selectStorybook = hooks.useState(nil)
	local sidebarWidth, setSidebarWidth = hooks.useState(props.initialsSidebarWidth)

	local selectStory = hooks.useCallback(function(newStory: ModuleScript)
		setStory(function(prevStory: ModuleScript)
			return if prevStory ~= newStory then newStory else nil
		end)
	end, { setStory })

	local onSidebarResized = hooks.useCallback(function(newSize: Vector2)
		setSidebarWidth(newSize.X)
	end, {})

	return Roact.createElement(PluginContext.Provider, {
		plugin = props.plugin,
	}, {
		Background = Roact.createElement("Frame", {
			BackgroundColor3 = theme.background,
			Size = UDim2.fromScale(1, 1),
		}, {
			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			SidebarWrapper = Roact.createElement(ResizablePanel, {
				layoutOrder = 1,
				initialSize = UDim2.new(0, props.initialsSidebarWidth, 1, 0),
				dragHandles = { "Right" },
				minSize = Vector2.new(props.minSidebarWidth, 0),
				maxSize = Vector2.new(props.maxSidebarWidth, math.huge),
				onResize = onSidebarResized,
			}, {
				Sidebar = Roact.createElement(Sidebar, {
					selectStory = selectStory,
					selectStorybook = selectStorybook,
					storybooks = storybooks,
				}),
			}),

			MainWrapper = Roact.createElement("Frame", {
				LayoutOrder = 2,
				Size = UDim2.fromScale(1, 1) - UDim2.fromOffset(sidebarWidth, 0),
			}, {
				Canvas = Roact.createElement(Canvas, {
					loader = loader,
					story = story,
					storybook = storybook,
				}),
			}),
		}),
	})
end

return hook(App)
