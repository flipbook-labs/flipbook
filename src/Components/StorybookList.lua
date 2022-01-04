local Roact = require(script.Parent.Parent.Packages.Roact)
local Llama = require(script.Parent.Parent.Packages.Llama)
local styles = require(script.Parent.Parent.styles)
local types = require(script.Parent.Parent.types)

export type Props = {
	storybooks: { types.Storybook },
	onStorybookSelected: ((types.Storybook) -> nil)?,
}

local function StorybookList(props: Props)
	local children = {}

	children.Layout = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	for index, storybook in ipairs(props.storybooks) do
		children[storybook.name] = Roact.createElement(
			"TextButton",
			Llama.Dictionary.join(styles.TextLabel, {
				LayoutOrder = index,
				Text = storybook.name,
				Size = UDim2.new(1, 0, 0, styles.TextLabel.TextSize),
				[Roact.Event.Activated] = function()
					props.onStorybookSelected(storybook)
				end,
			})
		)
	end

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, children)
end

return StorybookList
