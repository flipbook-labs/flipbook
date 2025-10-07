--!strict
local root = script.Parent.Parent
local networkingChatTypes = require(root.networkingChatTypes)
local CHAT_URL = require(root.CHAT_URL)

return function(config: networkingChatTypes.Config): networkingChatTypes.ResetConversationUniverseRequest
	local roduxNetworking = config.roduxNetworking

	return roduxNetworking.POST({ Name = "ResetConversationUniverse" }, function(requestBuilder, conversationId)
		return requestBuilder(CHAT_URL):path("v2"):path("reset-conversation-universe"):body({
			conversationId = conversationId,
		}):setStatusIds({ conversationId })
	end)
end
