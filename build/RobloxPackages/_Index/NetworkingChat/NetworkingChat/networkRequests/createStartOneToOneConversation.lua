--!strict
local root = script.Parent.Parent
local networkingChatTypes = require(root.networkingChatTypes)
local CHAT_URL = require(root.CHAT_URL)

return function(config: networkingChatTypes.Config): networkingChatTypes.StartOneToOneConversationRequest
	local roduxNetworking = config.roduxNetworking

	return roduxNetworking.POST({ Name = "StartOneToOneConversation" }, function(requestBuilder, participantUserId)
		return requestBuilder(CHAT_URL):path("v2"):path("start-one-to-one-conversation"):body({
			participantUserId = participantUserId,
		}):setStatusIds({ participantUserId })
	end)
end
