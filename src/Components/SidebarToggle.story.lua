local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local SidebarToggle = require(script.Parent.SidebarToggle)

local function Story(_props, hooks: any)
	local isExpanded, set = hooks.useState(true)

	local toggle = hooks.useCallback(function()
		set(function(prev)
			return not prev
		end)
	end, {})

	return Roact.createElement(SidebarToggle, {
		isExpanded = isExpanded,
		onActivated = toggle,
	})
end

Story = RoactHooks.new(Roact)(Story)

return {
	story = Roact.createElement(Story),
}
