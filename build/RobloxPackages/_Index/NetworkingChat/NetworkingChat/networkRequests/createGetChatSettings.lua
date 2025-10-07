--!strict
local root = script.Parent.Parent
local networkingChatTypes = require(root.networkingChatTypes)
local CHAT_URL = require(root.CHAT_URL)

return function(config: networkingChatTypes.Config): networkingChatTypes.GetChatSettingsRequest
	local roduxNetworking = config.roduxNetworking

	return roduxNetworking.GET({ Name = "GetChatSettings" }, function(requestBuilder)
		return requestBuilder(CHAT_URL):path("v2"):path("chat-settings")
	end)
end
