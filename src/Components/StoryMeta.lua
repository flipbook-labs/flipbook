local SelectionService = game:GetService("Selection")

local Llama = require(script.Parent.Parent.Packages.Llama)
local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local assets = require(script.Parent.Parent.assets)
local styles = require(script.Parent.Parent.styles)
local types = require(script.Parent.Parent.types)
local Panel = require(script.Parent.Panel)
local StoryControl = require(script.Parent.StoryControl)
local Button = require(script.Parent.Button)

export type Props = {
	layoutOrder: number,
	story: types.Story,
	storyModule: ModuleScript,
	storyParent: any,
	controls: types.Controls?,
	onControlChanged: ((string, any) -> ())?,
	onViewportToggled: (() -> ())?,
}

local function StoryMeta(props: Props, hooks: any)
	local controlFields = {}
	local hasControls = props.controls and not Llama.isEmpty(props.controls)

	if hasControls then
		local controls = Llama.Dictionary.values(Llama.Dictionary.map(props.controls, function(value, key)
			return { name = key, value = value }
		end))

		for index, control in ipairs(controls) do
			controlFields[control.name] = Roact.createElement(StoryControl, {
				layoutOrder = index + 1,
				key = control.name,
				value = control.value,
				onValueChange = function(newValue: any)
					if props.onControlChanged then
						props.onControlChanged(control.name, newValue)
					end
				end,
			})
		end
	end

	local selectGui = hooks.useCallback(function()
		SelectionService:Set({ props.storyParent:getValue() })
	end, { props.storyParent })

	local selectModule = hooks.useCallback(function()
		SelectionService:Set({ props.storyModule })
	end, { props.storyModule })

	return Roact.createElement("Frame", {
		LayoutOrder = props.layoutOrder,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Topbar = Roact.createElement(Panel, {
			layoutOrder = 1,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = styles.PADDING,
			}),

			Title = Roact.createElement(
				"TextLabel",
				Llama.Dictionary.join(styles.Header, {
					LayoutOrder = 1,
					Text = props.story.name,
					Size = UDim2.fromScale(1 / 2, 0),
				})
			),

			Buttons = Roact.createElement("Frame", {
				LayoutOrder = 2,
				Size = UDim2.fromScale(1 / 2, 1),
				BackgroundTransparency = 1,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					Padding = styles.LARGE_PADDING,
				}),

				Explore = Roact.createElement(Button, {
					layoutOrder = 1,
					icon = assets.explore,
					onActivated = selectGui,
				}),

				SelectModule = Roact.createElement(Button, {
					layoutOrder = 2,
					icon = assets.story,
					onActivated = selectModule,
				}),

				MountInViewport = Roact.createElement(Button, {
					layoutOrder = 3,
					icon = assets.viewport,
					onActivated = props.onViewportToggled,
				}),
			}),
		}),

		Summary = props.story.summary and Roact.createElement(Panel, {
			layoutOrder = 2,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = styles.PADDING,
			}),

			Title = Roact.createElement(
				"TextLabel",
				Llama.Dictionary.join(styles.Header, {
					LayoutOrder = 1,
					Text = "Summary",
				})
			),

			Body = Roact.createElement(
				"TextLabel",
				Llama.Dictionary.join(styles.TextLabel, {
					LayoutOrder = 2,
					Text = props.story.summary,
				})
			),
		}),

		Controls = hasControls and Roact.createElement(Panel, {
			layoutOrder = 3,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = styles.PADDING,
			}),

			Title = Roact.createElement(
				"TextLabel",
				Llama.Dictionary.join(styles.Header, {
					LayoutOrder = 1,
					Text = "Controls",
				})
			),

			Controls = Roact.createFragment(controlFields),
		}),
	})
end

return RoactHooks.new(Roact)(StoryMeta)
