local constants = require(script.Parent.Parent.Parent.constants)
local ExplorerNode = require(script.Parent.ExplorerNode)
local fromHex = require(script.Parent.Parent.Parent.Modules.fromHex)
local hook = require(script.Parent.Parent.Parent.hook)
local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local types = require(script.Parent.types)

local e = Roact.createElement

local childNode = {
	icon = "story",
	name = "TestComponent.story",
}

local parentNode = {
	children = { childNode },
	icon = "folder",
	name = "TestFolder",
}

local function ExplorerNodeStory(_, hooks: any)
	local state, set = hooks.useState(nil)
	local onNodeActivated = hooks.useCallback(function(node: types.Node)
		if node.name:match(constants.STORY_NAME_PATTERN) then
			set(function(prevState)
				return if node == prevState then nil else node
			end)
		end
	end, { state, set })

	return e("Frame", {
		BackgroundColor3 = fromHex(0xF3F4F6),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 200, 1, 0),
	}, {
		Node = e(ExplorerNode, {
			activeNode = state,
			node = parentNode,
			onNodeActivated = onNodeActivated,
		}),
	})
end

ExplorerNodeStory = hook(ExplorerNodeStory)

return {
	story = Roact.createElement(ExplorerNodeStory),
}
