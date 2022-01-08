local Llama = require(script.Parent.Parent.Packages.Llama)
local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local styles = require(script.Parent.Parent.styles)
local types = require(script.Parent.Parent.types)
local Panel = require(script.Parent.Panel)
local StoryControl = require(script.Parent.StoryControl)

export type Props = {
	layoutOrder: number,
	story: types.Story,
	controls: Dictionary<any>?,
	onControlChanged: ((string, any) -> nil)?,
}

local function StoryMeta(props: Props)
	local controlFields = {}
	local hasControls = props.controls and #props.controls > 0

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

		Summary = props.story.summary and Roact.createElement(Panel, {
			layoutOrder = 1,
		}, {
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
			layoutOrder = 2,
		}, {
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
