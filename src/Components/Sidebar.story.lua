local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)

local Sidebar = require(script.Parent.Sidebar)

local function Story(_props, hooks)
	local isExpanded, set = hooks.useState(true)

	local toggle = hooks.useCallback(function()
		set(function(prev)
			return not prev
		end)
	end, {})

	return Roact.createElement(Sidebar, {
		storybooks = {
			require(script.Parent.Parent["init.storybook"]),
		},
		width = NumberRange.new(24, 250),
		selectStory = print,
		isExpanded = isExpanded,
		onToggleActivated = toggle,
	})
end

Story = RoactHooks.new(Roact)(Story)

return {
	summary = "The sidebar that displays all the available stories for the current Storybook",
	story = Roact.createElement(Story),
}
