local Llama = require(script.Parent.Parent.Packages.Llama)
local Roact = require(script.Parent.Parent.Packages.Roact)
local constants = require(script.Parent.Parent.constants)
local styles = require(script.Parent.Parent.styles)

export type Props = {
	stories: { ModuleScript },
	onStorySelected: (ModuleScript) -> nil,
}

local function StoryList(props: Props)
	local children = {}

	children.Layout = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	for index, story in ipairs(props.stories) do
		local name = story.Name:gsub(constants.STORY_NAME_PATTERN, "")

		children[name] = Roact.createElement(
			"TextButton",
			Llama.Dictionary.join(styles.TextLabel, {
				LayoutOrder = index,
				Text = name,
				Size = UDim2.new(1, 0, 0, styles.TextLabel.TextSize),
				[Roact.Event.Activated] = function()
					props.onStorySelected(story)
				end,
			}),
			{
				Padding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
					PaddingBottom = UDim.new(0, 8),
					PaddingLeft = UDim.new(0, 8),
				}),
			}
		)
	end

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, children)
end

return StoryList
