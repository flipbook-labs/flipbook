local ExplorerNode = require(script.Parent.ExplorerNode)
local fromHex = require(script.Parent.Parent.Parent.Modules.fromHex)
local Roact = require(script.Parent.Parent.Parent.Packages.Roact)

return function(t)
	local h = Roact.mount(
		Roact.createElement("Frame", {
			Size = UDim2.new(0, 200, 1, 0),
			BackgroundColor3 = fromHex(0xF3F4F6),
			BorderSizePixel = 0,
		}, {
			Node = Roact.createElement(ExplorerNode, {
				node = {
					name = "Test Node",
					icon = "folder",
					children = {
						{
							name = "Test Node 2",
							icon = "story",
						},
					},
				},
			}),
		}),
		t
	)

	return function()
		Roact.unmount(h)
	end
end
