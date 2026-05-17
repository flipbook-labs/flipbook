local CollectionService = game:GetService("CollectionService")

local constants = require("@root/constants")

local function getTaggedRuntimes(): { Instance }
	return CollectionService:GetTagged(constants.FLIPBOOK_RUNTIME_TAG)
end

return getTaggedRuntimes
