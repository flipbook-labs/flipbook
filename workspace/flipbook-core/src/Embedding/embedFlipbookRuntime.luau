local CollectionService = game:GetService("CollectionService")

local constants = require("@root/constants")

local function embedFlipbookRuntime(target: Instance)
	local pluginRoot =
		assert(script:FindFirstAncestor("Flipbook"), `attempt to embed failed (could not find a "Flipbook" ancestor)`)

	local existing = CollectionService:GetTagged(constants.FLIPBOOK_RUNTIME_TAG)
	if #existing > 0 then
		for _, instance in existing do
			instance:Destroy()
		end
	end

	-- It's a bit of a bummer that we have to clone our own build of Flipbook
	-- for use as the embedded runtime. If I'm on a dev build I might want to
	-- use a prod build for the experience. It looks like SerializationService
	-- would be able to deserialize an rbxm buffer we download from GitHub, but
	-- I think for now we'll just clone the built-in one for simplicity. Most
	-- users are going to be on prod anyway, so it would actually be less
	-- efficient to go and download the same build.
	local embeddedFlipbook = pluginRoot:Clone()

	CollectionService:AddTag(embeddedFlipbook, constants.FLIPBOOK_RUNTIME_TAG)

	embeddedFlipbook.Parent = target

	return embeddedFlipbook
end

return embedFlipbookRuntime
