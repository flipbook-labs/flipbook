-- Exit immediately if this script isn't running in an embedded context.
local PluginDebugService: PluginDebugService? = game:FindService("PluginDebugService")
if PluginDebugService and PluginDebugService:IsAncestorOf(script) then
	return
end

local startTime = os.clock()
local prefix = `[{script.Name}]`

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

print(`{prefix} starting...`)

print(`{prefix} disabling character auto-loading...`)
Players.CharacterAutoLoads = false

print(`{prefix} setting up HTTP proxy...`)
local httpProxy = Instance.new("RemoteFunction")
httpProxy.Name = "FlipbookHttpProxy"
httpProxy.Parent = script
httpProxy:AddTag("FlipbookHttpProxy")

httpProxy.OnServerInvoke = function(_player, url, method, headers, body)
	return HttpService:RequestAsync({
		Url = url,
		Method = method,
		Headers = headers,
		Body = body,
	})
end

print(`{prefix} successfully initialized in {os.clock() - startTime}s`)
