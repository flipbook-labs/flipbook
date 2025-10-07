local DefaultHttpService = game:GetService("HttpService")
local DefaultMemStorageService = game:GetService("MemStorageService")
local DefaultPlayersService = game:GetService("Players")

local FFlagLogFirstGuacRead = game:DefineFastFlag("FFlagLogFirstGuacRead", false)
local FFlagLogAllGuacRead = game:DefineFastFlag("FFlagLogAllGuacRead", false)
local FFlagCacheReadParsePolicy = game:DefineFastFlag("CacheReadParsePolicy", false)

local CorePackages
local LoggingProtocol
if FFlagLogFirstGuacRead then
	CorePackages = game:GetService("CorePackages")
	LoggingProtocol = require(CorePackages.Workspace.Packages.LoggingProtocol).default
end

return function(dependencies)
	dependencies = dependencies or {}
	dependencies.HttpService = dependencies.HttpService or DefaultHttpService
	dependencies.MemStorageService = dependencies.MemStorageService or DefaultMemStorageService
	dependencies.PlayersService = dependencies.PlayersService or DefaultPlayersService

	assert(dependencies.HttpService, "expected dependencies.HttpService")
	assert(dependencies.MemStorageService, "expected dependencies.MemStorageService")
	assert(dependencies.PlayersService, "expected dependencies.PlayersService")

	local HttpService = dependencies.HttpService
	local MemStorageService = dependencies.MemStorageService
	local PlayersService = dependencies.PlayersService
	local readReported = false

	return function(behavior)
		assert(behavior, "expected behavior")

		local function getStoreKey()
			local userId = -1
			-- AppConfiguration::generateStoreKey() uses -1 as the default userId
			local player = PlayersService.LocalPlayer
			if player and player.UserId > 0 then
				userId = player.UserId
			end
			return "GUAC:" .. userId .. ":" .. behavior
		end

		local connectionStoreKey
		local memStorageConnection
		local previouslyReadJsonValue
		local previouslyReadPolicy

		local onPolicyChangedEvent = Instance.new("BindableEvent")

		if FFlagCacheReadParsePolicy then
			-- since storeKey uses player ID, let's make sure we invalidate if it ever changes
			local userIdConn
			local function localPlayerChanged()
				if userIdConn then
					userIdConn:Disconnect()
					userIdConn = nil
				end
				if PlayersService.LocalPlayer then
					userIdConn = PlayersService.LocalPlayer:GetPropertyChangedSignal("UserId"):Connect(function()
						previouslyReadPolicy = nil
					end)
				end
				previouslyReadPolicy = nil
			end
			PlayersService:GetPropertyChangedSignal("LocalPlayer"):Connect(localPlayerChanged)
			localPlayerChanged()
		end

		local function onPolicyUpdated(newPolicyData)
			-- MemStorageService will not de-duplicate the same item from storage
			if newPolicyData ~= previouslyReadJsonValue then
				if newPolicyData and #newPolicyData > 0 then
					local success, decodedExternalPolicy = pcall(function()
						return HttpService:JSONDecode(newPolicyData)
					end)
					if success then
						-- never store garbage
						previouslyReadJsonValue = newPolicyData
						previouslyReadPolicy = decodedExternalPolicy
						onPolicyChangedEvent:Fire(decodedExternalPolicy)
					end
				end
			end
		end

		return {
			read = function()
				if FFlagCacheReadParsePolicy and previouslyReadPolicy then
					return previouslyReadPolicy
				end
				local storeKey = getStoreKey()
				local policyData = MemStorageService:GetItem(storeKey)
				if policyData and #policyData > 0 then
					local success, policy = pcall(function()
						return HttpService:JSONDecode(policyData)
					end)
					if success then
						if FFlagLogAllGuacRead then
							LoggingProtocol:logEvent("lua_policy_read_success")
						elseif FFlagLogFirstGuacRead then
							if not readReported then
								LoggingProtocol:logEvent("lua_policy_read_success")
								readReported = true
							end
						end
						-- Be sure to store the json string
						previouslyReadPolicy = policy
						previouslyReadJsonValue = policyData
						return policy
					end
				end

				return nil
			end,

			onPolicyChanged = function(func)
				local storeKey = getStoreKey()

				local connection = onPolicyChangedEvent.Event:Connect(func)

				if memStorageConnection and connectionStoreKey == storeKey then
					-- Fire listener with existing value
					if previouslyReadPolicy then
						func(previouslyReadPolicy)
					end
				else
					if memStorageConnection then
						memStorageConnection:Disconnect()
					end
					connectionStoreKey = storeKey
					memStorageConnection = MemStorageService:BindAndFire(storeKey, onPolicyUpdated)
				end

				return connection
			end,
		}
	end
end
