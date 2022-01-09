local SelectionService = game:GetService("SelectionService")

local Llama = require(script.Parent.Parent.Packages.Llama)
local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local styles = require(script.Parent.Parent.styles)
local types = require(script.Parent.Parent.types)
local Panel = require(script.Parent.Panel)
local StoryControl = require(script.Parent.StoryControl)
local Button = require(script.Parent.Button)

export type Props = {
	layoutOrder: number,
	story: types.Story,
	controls: Dictionary<any>?,
	onControlChanged: ((string, any) -> nil)?,
}

local function StoryMeta(props: Props)
	local controlFields = {}
	local hasControls = props.controls and not Llama.isEmpty(props.controls)

	if hasControls then
		for key, value in pairs(props.controls) do
			table.insert(
				controlFields,
				Roact.createElement(StoryControl, {
					key = key,
					value = value,
					onValueChange = function(newValue: any)
						if props.onControlChanged then
							props.onControlChanged(key, newValue)
						end
					end,
				})
			)
		end
	end

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
					text = "Explore",
				}),

				SelectModule = Roact.createElement(Button, {
					layoutOrder = 2,
					text = "Select Story",
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
					LayoutOrder = 0,
					Text = "Controls",
				})
			),

			Controls = Roact.createFragment(controlFields),
		}),
	})
end

return RoactHooks.new(Roact)(StoryMeta)
