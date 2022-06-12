local flipbook = script:FindFirstAncestor("flipbook")

local Brand = require(flipbook.Components.Sidebar.Brand)
local Roact = require(flipbook.Packages.Roact)

return function(t)
	local handle = Roact.mount(Roact.createElement(Brand), t)

	return function()
		Roact.unmount(handle)
	end
end
