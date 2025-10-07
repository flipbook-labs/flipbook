--!strict
local root = script.Parent.Parent
local networkingChatTypes = require(root.networkingChatTypes)
local CHAT_URL = require(root.CHAT_URL)

return function(config: networkingChatTypes.Config): networkingChatTypes.GetRolloutSettingsRequest
	local roduxNetworking = config.roduxNetworking

	return roduxNetworking.GET({ Name = "GetRolloutSettings" }, function(requestBuilder, featureNames)
		return requestBuilder(CHAT_URL):path("v2"):path("get-rollout-settings"):expandedQueryArgsWithIds("featureNames", featureNames)
	end)
end
