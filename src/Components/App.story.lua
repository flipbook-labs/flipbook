local flipbook = script:FindFirstAncestor("flipbook")

local App = require(flipbook.Components.App)
local Roact = require(flipbook.Packages.Roact)

return function(t)
	local handle = Roact.mount(Roact.createElement(App), t)

	return function()
		Roact.unmount(handle)
	end
end
