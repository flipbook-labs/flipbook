--!strict
local root = script.Parent.Parent
local networkingChatTypes = require(root.networkingChatTypes)
local CHAT_URL = require(root.CHAT_URL)

return function(config: networkingChatTypes.Config): networkingChatTypes.GetConversationsRequest
	local roduxNetworking = config.roduxNetworking

	return roduxNetworking.GET({ Name = "GetConversations" }, function(requestBuilder, conversationIds)
		return requestBuilder(CHAT_URL):path("v2"):path("get-conversations"):expandedQueryArgsWithIds("conversationIds", conversationIds)
	end)
end
