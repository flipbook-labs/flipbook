--!strict
local root = script.Parent.Parent
local networkingChatTypes = require(root.networkingChatTypes)
local CHAT_URL = require(root.CHAT_URL)

return function(config: networkingChatTypes.Config): networkingChatTypes.UpdateUserTypingStatusRequest
	local roduxNetworking = config.roduxNetworking

	return roduxNetworking.POST({ Name = "UpdateUserTypingStatus" }, function(requestBuilder, conversationId, isTyping)
		return requestBuilder(CHAT_URL):path("v2"):path("update-user-typing-status"):body({
			conversationId = conversationId,
			isTyping = isTyping,
		}):setStatusIds({ conversationId })
	end)
end
