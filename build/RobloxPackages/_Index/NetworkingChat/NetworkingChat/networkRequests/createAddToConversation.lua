--!strict
local root = script.Parent.Parent
local networkingChatTypes = require(root.networkingChatTypes)
local CHAT_URL = require(root.CHAT_URL)

return function(config: networkingChatTypes.Config): networkingChatTypes.AddToConversationRequest
	local roduxNetworking = config.roduxNetworking

	return roduxNetworking.POST({ Name = "AddToConversation" }, function(requestBuilder, participantUserIds, conversationId)
		return requestBuilder(CHAT_URL):path("v2"):path("add-to-conversation"):body({
			participantUserIds = participantUserIds,
			conversationId = conversationId,
		}):setStatusIds({ conversationId })
	end)
end
