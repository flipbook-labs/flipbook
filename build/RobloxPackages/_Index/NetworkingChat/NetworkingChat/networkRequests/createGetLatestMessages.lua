--!strict
local root = script.Parent.Parent
local networkingChatTypes = require(root.networkingChatTypes)
local CHAT_URL = require(root.CHAT_URL)

return function(config: networkingChatTypes.Config): networkingChatTypes.GetLatestMessagesRequest
	local roduxNetworking = config.roduxNetworking

	return roduxNetworking.GET({ Name = "GetLatestMessages" }, function(requestBuilder, conversationIds, pageSize)
		return requestBuilder(CHAT_URL):path("v2"):path("multi-get-latest-messages"):queryArgs({
			pageSize = pageSize,
		}):expandedQueryArgsWithIds("conversationIds", conversationIds)
	end)
end
