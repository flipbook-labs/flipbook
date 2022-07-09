local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local RoactSpring = require(flipbook.Packages.RoactSpring)
local assets = require(flipbook.assets)
local constants = require(flipbook.constants)
local hook = require(flipbook.hook)
local useDark = require(flipbook.Hooks.useDark)
local useTailwind = require(flipbook.Hooks.useTailwind)
local types = require(script.Parent.Parent.types)

local e = Roact.createElement

type Props = {
	expanded: boolean,
	hasChildren: boolean,
	indent: number,
	node: types.Node,
	onClick: (types.Node) -> (),
}

local function Directory(props: Props, hooks: any)
	local dark = useDark(hooks)
	local hover, setHover = hooks.useState(false)
	local styles = RoactSpring.useSpring(hooks, {
		alpha = if hover then 0 else 1,
		rotation = if props.expanded then 90 else 0,
		config = constants.SPRING_CONFIG,
	})

	return e("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = useTailwind("gray-200", "gray-200", dark),
		BackgroundTransparency = styles.alpha,
		LayoutOrder = 0,
		Size = UDim2.new(1, 0, 0, 36),
		Text = "",
		[Roact.Event.MouseEnter] = function()
			setHover(true)
		end,
		[Roact.Event.MouseLeave] = function()
			setHover(false)
		end,
		[Roact.Event.Activated] = function()
			props.onClick(props.node)
		end,
	}, {
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),

		UIPadding = e("UIPadding", {
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 8 * (props.indent + 1)),
			PaddingRight = UDim.new(0, 6),
			PaddingTop = UDim.new(0, 10),
		}),

		Detail = e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -16, 1, 0),
		}, {
			UIListLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			Icon = e("ImageLabel", {
				BackgroundTransparency = 1,
				Image = if props.node.icon == "folder" then assets.Folder else assets.Storybook,
				ImageColor3 = if props.node.icon == "folder"
					then useTailwind("purple-500")
					else useTailwind("gray-600", "gray-600", dark),
				LayoutOrder = 0,
				Size = UDim2.fromOffset(16, 16),
			}),

			Typography = e("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamMedium,
				LayoutOrder = 1,
				Size = UDim2.fromOffset(0, 0),
				-- TODO: Do string parsing to get rid of `.storybook`
				Text = props.node.name,
				TextColor3 = useTailwind("gray-600", "gray-600", dark),
				TextSize = 14,
			}),
		}),

		Chevron = e("ImageLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = 1,
			Image = assets.ChevronRight,
			ImageColor3 = useTailwind("gray-800", "gray-800", dark),
			Position = UDim2.fromScale(1, 0.5),
			Rotation = styles.rotation,
			Size = UDim2.fromOffset(16, 16),
		}),
	})
end

return hook(Directory)
