local HelloWorld = require(script.Parent.HelloWorld)
local Roact = require(script.Parent.Parent.Roact)

return function(target)
	local root = Roact.createElement(HelloWorld, {
		name = "Flipbook",
	})

	local handle = Roact.mount(root, target)

	return function()
		Roact.unmount(handle)
	end
end
