--!strict
local root = script.Parent.Parent
local networkingChatTypes = require(root.networkingChatTypes)
local CHAT_URL = require(root.CHAT_URL)

return function(config: networkingChatTypes.Config): networkingChatTypes.RemoveFromConversationRequest
	local roduxNetworking = config.roduxNetworking

	return roduxNetworking.POST({ Name = "RemoveFromConversation" }, function(requestBuilder, participantUserId, conversationId)
		return requestBuilder(CHAT_URL):path("v2"):path("remove-from-conversation"):body({
			participantUserId = participantUserId,
			conversationId = conversationId,
		}):setStatusIds({ conversationId })
	end)
end
