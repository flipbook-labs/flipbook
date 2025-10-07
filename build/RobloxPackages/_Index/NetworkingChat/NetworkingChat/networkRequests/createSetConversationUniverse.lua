--!strict
local root = script.Parent.Parent
local networkingChatTypes = require(root.networkingChatTypes)
local CHAT_URL = require(root.CHAT_URL)

return function(config: networkingChatTypes.Config): networkingChatTypes.SetConversationUniverseRequest
	local roduxNetworking = config.roduxNetworking

	return roduxNetworking.POST({ Name = "SetConversationUniverse" }, function(requestBuilder, conversationId, universeId)
		return requestBuilder(CHAT_URL):path("v2"):path("set-conversation-universe"):body({
			conversationId = conversationId,
			universeId = universeId,
		}):setStatusIds({ conversationId })
	end)
end
