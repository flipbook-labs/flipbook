local React = require("@pkg/React")

local Group = require("@root/Group")
local Panel = require("@root/Panel")

-- Shared label used inside colored panels
local function PanelLabel(text: string, color: Color3)
	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
	}, {
		Label = React.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 1),
			Text = text,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
		}),
	})
end

-- Wraps a story with a title and fixed dimensions
local function StorySection(title: string, width: number, height: number, content: React.Node)
	return React.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, height + 28),
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.None,
	}, {
		Title = React.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 0, 22),
			Text = title,
			TextColor3 = Color3.fromRGB(180, 180, 180),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),

		Content = React.createElement("Frame", {
			Position = UDim2.fromOffset(0, 24),
			Size = UDim2.fromOffset(width, height),
			BackgroundColor3 = Color3.fromRGB(25, 25, 25),
			BorderSizePixel = 0,
		}, {
			Inner = content,
		}),
	})
end

-- Story 1: Basic three-panel horizontal group
local function BasicGroupStory(props: { minSize: number })
	return StorySection(
		"Basic — three panels (horizontal)",
		800,
		300,
		React.createElement(Group, { id = "basic", orientation = "horizontal" }, {
			A = React.createElement(
				Panel,
				{
					id = "a",
					LayoutOrder = 1,
					defaultSize = 25,
					sizeConstraints = NumberRange.new(props.minSize, math.huge),
				},
				PanelLabel("Panel A", Color3.fromRGB(50, 80, 120))
			),
			B = React.createElement(
				Panel,
				{
					id = "b",
					LayoutOrder = 2,
					defaultSize = 50,
					sizeConstraints = NumberRange.new(props.minSize, math.huge),
				},
				PanelLabel("Panel B", Color3.fromRGB(80, 50, 120))
			),
			C = React.createElement(
				Panel,
				{
					id = "c",
					LayoutOrder = 3,
					defaultSize = 25,
					sizeConstraints = NumberRange.new(props.minSize, math.huge),
				},
				PanelLabel("Panel C", Color3.fromRGB(120, 80, 50))
			),
		})
	)
end

-- Story 2: Nested groups
--
--   Group (horizontal)
--   ├── Panel "left"
--   ├── Panel (center)
--   │   └── Group (vertical)
--   │       ├── Panel "top"
--   │       └── Panel (bottom)
--   │           └── Group (horizontal)
--   │               ├── Panel "left"
--   │               └── Panel "right"
--   └── Panel "right"
local function NestedGroupsStory()
	return StorySection(
		"Nested groups",
		900,
		400,
		React.createElement(Group, { id = "outer", orientation = "horizontal" }, {
			Left = React.createElement(
				Panel,
				{ id = "left", LayoutOrder = 1, defaultSize = 20 },
				PanelLabel("left", Color3.fromRGB(60, 100, 160))
			),
			Center = React.createElement(
				Panel,
				{ id = "center", LayoutOrder = 2, defaultSize = 60 },
				React.createElement(Group, { id = "center-vertical", orientation = "vertical" }, {
					Top = React.createElement(
						Panel,
						{ id = "top", LayoutOrder = 1, defaultSize = 40 },
						PanelLabel("top", Color3.fromRGB(100, 60, 160))
					),
					Bottom = React.createElement(
						Panel,
						{ id = "bottom", LayoutOrder = 2, defaultSize = 60 },
						React.createElement(Group, { id = "bottom-horizontal", orientation = "horizontal" }, {
							BLeft = React.createElement(
								Panel,
								{ id = "bottom-left", LayoutOrder = 1, defaultSize = 50 },
								PanelLabel("left", Color3.fromRGB(60, 160, 100))
							),
							BRight = React.createElement(
								Panel,
								{ id = "bottom-right", LayoutOrder = 2, defaultSize = 50 },
								PanelLabel("right", Color3.fromRGB(160, 100, 60))
							),
						})
					),
				})
			),
			Right = React.createElement(
				Panel,
				{ id = "right", LayoutOrder = 3, defaultSize = 20 },
				PanelLabel("right", Color3.fromRGB(160, 60, 100))
			),
		})
	)
end

local controls = {
	minSize = 60,
}

type Props = {
	controls: typeof(controls),
}

return {
	summary = "Group — interactive resize demos",
	controls = controls,
	story = function(props: Props)
		return React.createElement("Frame", {
			Size = UDim2.fromOffset(960, 900),
			BackgroundColor3 = Color3.fromRGB(18, 18, 18),
		}, {
			Layout = React.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 24),
			}),
			Padding = React.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 16),
				PaddingTop = UDim.new(0, 16),
				PaddingRight = UDim.new(0, 16),
			}),

			Basic = React.createElement("Frame", {
				LayoutOrder = 1,
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
			}, BasicGroupStory({ minSize = props.controls.minSize })),

			Nested = React.createElement("Frame", {
				LayoutOrder = 2,
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
			}, NestedGroupsStory()),
		})
	end,
}
