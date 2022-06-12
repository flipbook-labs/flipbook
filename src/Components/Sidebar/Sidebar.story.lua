local flipbook = script:FindFirstAncestor("flipbook")

local Sidebar = require(flipbook.Components.Sidebar)
local Roact = require(flipbook.Packages.Roact)

return function(t)
	local handle = Roact.mount(Roact.createElement(Sidebar), t)

	return function()
		Roact.unmount(handle)
	end
end
