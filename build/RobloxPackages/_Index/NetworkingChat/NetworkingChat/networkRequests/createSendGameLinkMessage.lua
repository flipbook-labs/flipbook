--!strict
local root = script.Parent.Parent
local networkingChatTypes = require(root.networkingChatTypes)
local CHAT_URL = require(root.CHAT_URL)

return function(config: networkingChatTypes.Config): networkingChatTypes.SendGameLinkMessageRequest
	local roduxNetworking = config.roduxNetworking

	return roduxNetworking.POST({ Name = "SendGameLinkMessage" }, function(requestBuilder, universeId, conversationId, decorators)
		return requestBuilder(CHAT_URL):path("v2"):path("send-game-link-message"):body({
			universeId = universeId,
			conversationId = conversationId,
			decorators = decorators,
		}):setStatusIds({ conversationId })
	end)
end
