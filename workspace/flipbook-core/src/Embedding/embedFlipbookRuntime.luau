local CollectionService = game:GetService("CollectionService")

local constants = require("@root/constants")

local function embedFlipbookRuntime(target: Instance)
	local pluginRoot = script:FindFirstAncestor("Flipbook")

	local existing = CollectionService:GetTagged(constants.FLIPBOOK_RUNTIME_TAG)
	if #existing > 0 then
		for _, instance in existing do
			instance.Parent = nil
		end
	end

	-- It's a bit of a bummer that we have to clone our own build of Flipbook
	-- for use as the embedded runtime. If I'm on a dev build I might want to
	-- use a prod build for the experience. I'd like to pull the rbxm from the
	-- GitHub releases like flipbook-cli does but I'm not sure there's an engine
	-- API that could turn that into an Instance.
	local embeddedFlipbook = pluginRoot:Clone()

	CollectionService:AddTag(embeddedFlipbook, constants.FLIPBOOK_RUNTIME_TAG)

	embeddedFlipbook.Parent = target

	return embeddedFlipbook
end

return embedFlipbookRuntime
