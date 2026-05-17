local CollectionService = game:GetService("CollectionService")

local constants = require("@root/constants")
local enforceSingleRuntime = require("@root/Embedding/runtime/enforceSingleRuntime")

local function tagRuntime(runtime: Instance)
	enforceSingleRuntime(runtime)
	CollectionService:AddTag(runtime, constants.FLIPBOOK_RUNTIME_TAG)
end

return tagRuntime
