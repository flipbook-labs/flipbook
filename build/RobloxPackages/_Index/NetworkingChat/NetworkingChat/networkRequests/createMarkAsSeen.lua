--!strict
local root = script.Parent.Parent
local networkingChatTypes = require(root.networkingChatTypes)
local CHAT_URL = require(root.CHAT_URL)

return function(config: networkingChatTypes.Config): networkingChatTypes.MarkAsSeenRequest
	local roduxNetworking = config.roduxNetworking

	return roduxNetworking.POST({ Name = "MarkAsSeen" }, function(requestBuilder, conversationsToMarkSeen)
		return requestBuilder(CHAT_URL):path("v2"):path("mark-as-seen"):body({
			conversationsToMarkSeen = conversationsToMarkSeen,
		}):setStatusIds(conversationsToMarkSeen)
	end)
end
