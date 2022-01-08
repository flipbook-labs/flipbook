local Llama = require(script.Parent.Parent.Packages.Llama)
local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local styles = require(script.Parent.Parent.styles)
local types = require(script.Parent.Parent.types)
local Panel = require(script.Parent.Panel)

export type Props = {
	layoutOrder: number,
	story: types.Story,
}

local function StoryMeta(props: Props)
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

		Controls = props.story.controls and Roact.createElement(Panel, {
			layoutOrder = 2,
		}, {
			Title = Roact.createElement(
				"TextLabel",
				Llama.Dictionary.join(styles.Header, {
					LayoutOrder = 1,
					Text = "Controls",
				})
			),
		}),
	})
end

return RoactHooks.new(Roact)(StoryMeta)
