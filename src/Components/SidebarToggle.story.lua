local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local styles = require(script.Parent.Parent.styles)
local SidebarToggle = require(script.Parent.SidebarToggle)

local function Story(_props, hooks: any)
	local isExpanded, set = hooks.useState(true)

	local toggle = hooks.useCallback(function()
		set(function(prev)
			return not prev
		end)
	end, {})

	return Roact.createFragment({
		Padding = Roact.createElement("UIPadding", {
			PaddingTop = styles.LARGE_PADDING,
			PaddingRight = styles.LARGE_PADDING,
			PaddingBottom = styles.LARGE_PADDING,
			PaddingLeft = styles.LARGE_PADDING,
		}),

		Story = Roact.createElement(SidebarToggle, {
			isExpanded = isExpanded,
			onActivated = toggle,
		}),
	})
end

Story = RoactHooks.new(Roact)(Story)

return {
	roact = Roact,
	story = Roact.createElement(Story),
}
