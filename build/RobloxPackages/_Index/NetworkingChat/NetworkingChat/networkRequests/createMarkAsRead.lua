--!strict
local root = script.Parent.Parent
local networkingChatTypes = require(root.networkingChatTypes)
local CHAT_URL = require(root.CHAT_URL)

return function(config: networkingChatTypes.Config): networkingChatTypes.MarkAsReadRequest
	local roduxNetworking = config.roduxNetworking

	return roduxNetworking.POST({ Name = "MarkAsRead" }, function(requestBuilder, conversationId, endMessageId)
		return requestBuilder(CHAT_URL):path("v2"):path("mark-as-read"):body({
			conversationId = conversationId,
			endMessageId = endMessageId,
		}):setStatusIds({ conversationId })
	end)
end
