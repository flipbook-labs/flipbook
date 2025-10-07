--!strict
local root = script.Parent.Parent
local networkingChatTypes = require(root.networkingChatTypes)
local CHAT_URL = require(root.CHAT_URL)

return function(config: networkingChatTypes.Config): networkingChatTypes.SendMessageRequest
	local roduxNetworking = config.roduxNetworking

	return roduxNetworking.POST({ Name = "SendMessage" }, function(requestBuilder, message, conversationId, decorators)
		return requestBuilder(CHAT_URL):path("v2"):path("send-message"):body({
			message = message,
			conversationId = conversationId,
			decorators = decorators,
		}):setStatusIds({ conversationId })
	end)
end
