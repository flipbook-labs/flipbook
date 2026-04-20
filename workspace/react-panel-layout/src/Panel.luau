local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local PanelGroupContext = require("@root/PanelGroupContext")
local Window = require("@root/Window")

local useEffect = React.useEffect
local useState = React.useState

export type PanelProps = {
	id: string?,
	label: string?,
	LayoutOrder: number?,
	defaultSize: number?,
	sizeConstraints: NumberRange?,
	windowPlugin: Plugin?,
	windowIdPrefix: string?,
	children: React.Node?,
}

local defaultProps = {
	defaultSize = 50,
}

type Props = typeof(defaultProps) & PanelProps

local function Panel(panelProps: PanelProps)
	local context = PanelGroupContext.use()
	local props: Props = Sift.Dictionary.join(defaultProps, panelProps)
	local id = props.id or tostring(props.defaultSize)

	useEffect(function()
		context.registerPanel(id, props.defaultSize, props.sizeConstraints)

		return function()
			context.unregisterPanel(id)
		end
	end, {}) -- intentionally empty: registration is a mount/unmount side-effect

	local size = context.sizes[id] or props.defaultSize
	local isHorizontal = context.orientation == "horizontal"

	-- Collect Panel children to determine if this is a tabbed panel.
	-- Use pairs() so dictionary-style children are supported.
	type TabEntry = {
		index: number,
		layoutOrder: number,
		label: string,
		child: any,
	}

	local panelChildren: { TabEntry } = {}
	if props.children ~= nil then
		for _, child in pairs(props.children :: any) do
			if child ~= nil and typeof(child) == "table" and child.type == Panel then
				table.insert(panelChildren, {
					index = #panelChildren + 1,
					layoutOrder = child.props.LayoutOrder or 0,
					label = child.props.label or ("Tab " .. (#panelChildren + 1)),
					child = child,
				})
			end
		end
	end

	table.sort(panelChildren, function(a, b)
		return a.layoutOrder < b.layoutOrder
	end)

	local isTabbedPanel = #panelChildren > 0
	local activeTab, setActiveTab = useState(1)
	local poppedTabs, setPoppedTabs = useState({} :: { [number]: boolean })

	local content: React.Node
	if isTabbedPanel then
		-- Build visible tab list (tabs popped into windows are hidden from the strip)
		local visibleTabs: { TabEntry } = {}
		for _, tab in ipairs(panelChildren) do
			if not poppedTabs[tab.index] then
				table.insert(visibleTabs, tab)
			end
		end

		local activeEntry = nil :: TabEntry?
		for _, tab in ipairs(visibleTabs) do
			if tab.index == activeTab then
				activeEntry = tab
				break
			end
		end
		if activeEntry == nil then
			activeEntry = visibleTabs[1]
		end

		-- Build tab bar + content for each visible Panel child
		local tabButtons = {}
		for i, tab in ipairs(visibleTabs) do
			local isActive = activeEntry ~= nil and activeEntry.index == tab.index
			local capturedIndex = tab.index

			local tabChildren = {
				Label = React.createElement("TextButton", {
					LayoutOrder = 1,
					Text = tab.label,
					BackgroundTransparency = if isActive then 0 else 1,
					BackgroundColor3 = Color3.fromRGB(40, 40, 40),
					TextColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.X,
					Size = UDim2.fromScale(0, 1),
					[React.Event.Activated] = function()
						setActiveTab(capturedIndex)
					end,
				}, {
					Padding = React.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, 8),
						PaddingRight = UDim.new(0, 8),
					}),
				}),
			}

			if props.windowPlugin ~= nil then
				tabChildren.Pop = React.createElement("TextButton", {
					LayoutOrder = 2,
					Text = "pop",
					BackgroundTransparency = 1,
					TextColor3 = Color3.fromRGB(180, 180, 180),
					BorderSizePixel = 0,
					Size = UDim2.fromOffset(32, 0) + UDim2.fromScale(0, 1),
					[React.Event.Activated] = function()
						setPoppedTabs(function(prev)
							local next = table.clone(prev)
							next[capturedIndex] = true
							return next
						end)
					end,
				})
			end

			tabButtons["tab_" .. i] = React.createElement("Frame", {
				LayoutOrder = i,
				AutomaticSize = Enum.AutomaticSize.X,
				Size = UDim2.fromScale(0, 1),
				BackgroundTransparency = 1,
			}, {
				Layout = React.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				Children = React.createElement(React.Fragment, nil, tabChildren :: any),
			})
		end

		local windowNodes = {}
		if props.windowPlugin ~= nil then
			local idPrefix = props.windowIdPrefix or id
			for _, tab in ipairs(panelChildren) do
				if poppedTabs[tab.index] then
					local tabIndex = tab.index
					windowNodes["window_" .. tab.index] = React.createElement(Window, {
						id = string.format("%s_tab_%d", idPrefix, tabIndex),
						title = tab.label,
						plugin = props.windowPlugin,
						enabled = true,
						onEnabledChanged = function(enabled)
							if not enabled then
								setPoppedTabs(function(prev)
									local next = table.clone(prev)
									next[tabIndex] = nil
									return next
								end)
							end
						end,
					}, tab.child.props.children)
				end
			end
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
				Position = UDim2.fromOffset(0, 28),
				Size = UDim2.new(1, 0, 1, -28),
				BackgroundTransparency = 1,
			}, {
				Content = activeEntry ~= nil and React.createElement("Frame", {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
				}, activeEntry.child.props.children),
			}),

			PoppedWindows = React.createElement(React.Fragment, nil, windowNodes :: any),
		})
	else
		-- Single-content panel: render children directly
		content = React.createElement(React.Fragment, nil, props.children)
	end

	return React.createElement("Frame", {
		LayoutOrder = props.LayoutOrder,
		-- 0 base in the flex direction so GrowRatio distributes all available space
		-- proportionally rather than shrinking from an over-committed 100% base.
		Size = if isHorizontal then UDim2.fromScale(0, 1) else UDim2.fromScale(1, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
	}, {
		FlexItem = React.createElement("UIFlexItem", {
			FlexMode = Enum.UIFlexMode.Fill,
			GrowRatio = size,
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
