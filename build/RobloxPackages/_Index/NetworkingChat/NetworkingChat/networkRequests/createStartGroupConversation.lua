--!strict
local root = script.Parent.Parent
local networkingChatTypes = require(root.networkingChatTypes)
local CHAT_URL = require(root.CHAT_URL)

return function(config: networkingChatTypes.Config): networkingChatTypes.StartGroupConversationRequest
	local roduxNetworking = config.roduxNetworking

	return roduxNetworking.POST({ Name = "StartGroupConversation" }, function(requestBuilder, participantUserIds, title)
		return requestBuilder(CHAT_URL):path("v2"):path("start-group-conversation"):body({
			participantUserIds = participantUserIds,
			title = title,
		}):setStatusIds(participantUserIds)
	end)
end
