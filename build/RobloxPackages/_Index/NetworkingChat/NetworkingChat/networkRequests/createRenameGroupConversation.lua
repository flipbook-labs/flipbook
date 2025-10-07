--!strict
local root = script.Parent.Parent
local networkingChatTypes = require(root.networkingChatTypes)
local CHAT_URL = require(root.CHAT_URL)

return function(config: networkingChatTypes.Config): networkingChatTypes.RenameGroupConversationRequest
	local roduxNetworking = config.roduxNetworking

	return roduxNetworking.POST({ Name = "RenameGroupConversation" }, function(requestBuilder, conversationId, newTitle)
		return requestBuilder(CHAT_URL):path("v2"):path("rename-group-conversation"):body({
			conversationId = conversationId,
			newTitle = newTitle,
		}):setStatusIds({ conversationId })
	end)
end
