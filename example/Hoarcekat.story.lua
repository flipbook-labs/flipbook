local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.Roact)

return function(target: Instance)
	local root = Roact.createElement("TextLabel", {
		Text = "Hoarcekat Story",
		TextScaled = true,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.fromScale(1, 1),
	})

	local tree = Roact.mount(root, target)

	return function()
		Roact.unmount(tree)
	end
end
