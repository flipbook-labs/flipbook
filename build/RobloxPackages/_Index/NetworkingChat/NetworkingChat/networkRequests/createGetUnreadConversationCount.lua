--!strict
local root = script.Parent.Parent
local networkingChatTypes = require(root.networkingChatTypes)
local CHAT_URL = require(root.CHAT_URL)

return function(config: networkingChatTypes.Config): networkingChatTypes.GetUnreadConversationCountRequest
	local roduxNetworking = config.roduxNetworking

	return roduxNetworking.GET({ Name = "GetUnreadConversationCount" }, function(requestBuilder)
		return requestBuilder(CHAT_URL):path("v2"):path("get-unread-conversation-count")
	end)
end
