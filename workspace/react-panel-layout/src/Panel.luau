local React = require("@pkg/React")

local PanelGroupContext = require("@root/PanelGroupContext")
local types = require("@root/types")

local useEffect = React.useEffect
local useState = React.useState

export type Props = types.PanelProps

local DEFAULT_SIZE = 50

local function Panel(props: Props)
	local context = PanelGroupContext.use()
	local defaultSize = props.defaultSize or DEFAULT_SIZE
	local id = props.id or tostring(defaultSize)

	useEffect(function()
		context.registerPanel(id, defaultSize, props.sizeConstraints)

		return function()
			context.unregisterPanel(id)
		end
	end, {}) -- intentionally empty: registration is a mount/unmount side-effect

	local size = context.sizes[id] or defaultSize

	-- Collect Panel children to determine if this is a tabbed panel
	local panelChildren: { any } = {}
	local otherChildren: { any } = {}
	React.Children.forEach(props.children, function(child: any)
		if child ~= nil and typeof(child) == "table" and child.type == Panel then
			table.insert(panelChildren, child)
		else
			table.insert(otherChildren, child)
		end
	end)

	local isTabbedPanel = #panelChildren > 0
	local activeTab, setActiveTab = useState(1)

	local content: React.Node
	if isTabbedPanel then
		-- Build tab bar + content for each Panel child
		local tabButtons = {}
		local tabContents = {}
		for i, child in ipairs(panelChildren) do
			local tabLabel = child.props.label or ("Tab " .. i)
			local isActive = activeTab == i
			local capturedIndex = i
			tabButtons["tab_" .. i] = React.createElement("TextButton", {
				LayoutOrder = i,
				Text = tabLabel,
				BackgroundTransparency = if isActive then 0 else 1,
				BackgroundColor3 = Color3.fromRGB(40, 40, 40),
				TextColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				AutomaticSize = Enum.AutomaticSize.X,
				Size = UDim2.new(0, 0, 1, 0),
				[React.Event.Activated] = function()
					setActiveTab(capturedIndex)
				end,
			}, {
				Padding = React.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
				}),
			})

			tabContents["content_" .. i] = isActive
				and React.createElement("Frame", {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
				}, child.props.children)
		end

		content = React.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}, {
			TabBar = React.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 28),
				BackgroundColor3 = Color3.fromRGB(30, 30, 30),
				BorderSizePixel = 0,
			}, {
				Layout = React.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				Tabs = React.createElement(React.Fragment, nil, tabButtons :: any),
			}),

			ContentArea = React.createElement("Frame", {
				Position = UDim2.new(0, 0, 0, 28),
				Size = UDim2.new(1, 0, 1, -28),
				BackgroundTransparency = 1,
			}, tabContents :: any),
		})
	else
		-- Single-content panel: render children directly
		content = React.createElement(React.Fragment, nil, props.children)
	end

	return React.createElement("Frame", {
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
	}, {
		FlexItem = React.createElement("UIFlexItem", {
			FlexMode = Enum.UIFlexMode.Fill,
			GrowRatio = size,
			ShrinkRatio = size,
		}),

		Content = React.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}, {
			InnerContent = content,
		}),
	})
end

return Panel
