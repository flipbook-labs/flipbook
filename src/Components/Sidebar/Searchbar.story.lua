local flipbook = script:FindFirstAncestor("flipbook")

local Searchbar = require(flipbook.Components.Sidebar.Searchbar)
local Roact = require(flipbook.Packages.Roact)

return function(t)
	local handle = Roact.mount(Roact.createElement(Searchbar), t)

	return function()
		Roact.unmount(handle)
	end
end
