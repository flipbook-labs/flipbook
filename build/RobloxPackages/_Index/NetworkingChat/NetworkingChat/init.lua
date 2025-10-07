--!strict
local networkingChatTypes = require(script.networkingChatTypes)
local createRequestThunks = require(script.createRequestThunks)

local NetworkingChat: { config: (config: networkingChatTypes.Config) -> networkingChatTypes.RequestThunks  } = {
	config = createRequestThunks,
}

return NetworkingChat
