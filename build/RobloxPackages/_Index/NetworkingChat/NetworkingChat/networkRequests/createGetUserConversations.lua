--!strict
local root = script.Parent.Parent
local networkingChatTypes = require(root.networkingChatTypes)
local CHAT_URL = require(root.CHAT_URL)

return function(config: networkingChatTypes.Config): networkingChatTypes.GetUserConversationsRequest
	local roduxNetworking = config.roduxNetworking

	return roduxNetworking.GET({ Name = "GetUserConversations" }, function(requestBuilder, pageNumber, pageSize)
		return requestBuilder(CHAT_URL):path("v2"):path("get-user-conversations"):queryArgs({
			pageNumber = pageNumber,
			pageSize = pageSize,
		}):setStatusIds({ pageNumber })
	end)
end
