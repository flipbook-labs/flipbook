local Roact = require("@pkg/Roact")

local HelloWorldLabel = require("./HelloWorldLabel")

return function(target: Instance)
	local element = Roact.createElement(HelloWorldLabel, {
		name = "Flipbook",
	})

	local handle = Roact.mount(element, target)

	return function()
		Roact.unmount(handle)
	end
end
