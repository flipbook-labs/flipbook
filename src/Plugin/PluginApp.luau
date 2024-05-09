local Modal = require("@root/Modal/Modal")
local ModalPortal = require("@root/Modal/ModalPortal")
local ModalRoot = require("@root/Modal/ModalRoot")
local NavigationContext = require("@root/Navigation/NavigationContext")
local React = require("@pkg/React")
local ResizablePanel = require("@root/Panels/ResizablePanel")
local Screen = require("@root/Navigation/Screen")
local Sidebar = require("@root/Panels/Sidebar")
local Topbar = require("@root/Panels/Topbar")
local constants = require("@root/constants")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")
local useStorybooks = require("@root/Storybook/useStorybooks")
local useTheme = require("@root/Common/useTheme")

local TOPBAR_HEIGHT_PX = 32

export type Props = {
	loader: any,
}

local function App(props: Props)
	local theme = useTheme()
	local storybooks = useStorybooks(game, props.loader)
	local story, setStory = React.useState(nil)
	local storybook, selectStorybook = React.useState(nil)
	local sidebarWidth, setSidebarWidth = React.useState(constants.SIDEBAR_INITIAL_WIDTH)
	local navigation = NavigationContext.use()

	local selectStory = React.useCallback(function(newStory: ModuleScript)
		navigation.navigateTo("Home")

		setStory(function(prevStory: ModuleScript)
			return if prevStory ~= newStory then newStory else nil
		end)
	end, { setStory, navigation.navigateTo })

	local onSidebarResized = React.useCallback(function(newSize: Vector2)
		setSidebarWidth(newSize.X)
	end, {})

	local isModalShown, setIsModalShown = React.useState(true)
	local onCloseModal = React.useCallback(function()
		setIsModalShown(false)
	end, {})

	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		ModalRoot = React.createElement(ModalRoot),

		Sample = if isModalShown
			then React.createElement(ModalPortal, {}, {
				Modal = React.createElement(Modal, {
					title = "Example",
					onClose = onCloseModal,
				}, {}),
			})
			else nil,

		App = React.createElement("Frame", {
			BackgroundColor3 = theme.background,
			Size = UDim2.fromScale(1, 1),
		}, {
			Layout = React.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			SidebarWrapper = React.createElement(ResizablePanel, {
				layoutOrder = nextLayoutOrder(),
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
				LayoutOrder = nextLayoutOrder(),
				Size = UDim2.fromScale(1, 1) - UDim2.fromOffset(sidebarWidth, 0),
			}, {
				Layout = React.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				Topbar = React.createElement(Topbar, {
					Size = UDim2.new(1, 0, 0, TOPBAR_HEIGHT_PX),
					LayoutOrder = nextLayoutOrder(),
				}),

				ScreenWrapper = React.createElement("Frame", {
					LayoutOrder = nextLayoutOrder(),
					Size = UDim2.fromScale(1, 1) - UDim2.fromOffset(0, TOPBAR_HEIGHT_PX),
					BackgroundTransparency = 1,
				}, {
					Screen = React.createElement(Screen, {
						loader = props.loader,
						story = story,
						storybook = storybook,
					}),
				}),
			}),
		}),
	})
end

return App
