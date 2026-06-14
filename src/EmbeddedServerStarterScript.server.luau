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

-- The proxy runs HttpService:RequestAsync on the server on behalf of clients,
-- so it's a server-side request forgery risk: any player in the experience can
-- invoke it. Rather than gate on who's calling, we restrict where it can call —
-- only Flipbook's own backend — so the proxy can't be repurposed to probe or
-- POST to arbitrary endpoints the experience's HTTP allow-list permits.
local ALLOWED_HOST = "flipbooklabs.com"

local function isUrlAllowed(url: any): boolean
	if typeof(url) ~= "string" then
		return false
	end

	-- Require HTTPS and capture the authority (everything between the scheme
	-- and the first "/", "?" or "#").
	local authority = url:match("^https://([^/?#]+)")
	if not authority then
		return false
	end

	-- Drop any userinfo ("user@") and port so we compare the bare host. This
	-- also defeats `https://flipbooklabs.com@evil.com/` style spoofing.
	local host = authority:gsub("^[^@]*@", ""):gsub(":%d+$", ""):lower()

	return host == ALLOWED_HOST or host:sub(-(#ALLOWED_HOST + 1)) == `.{ALLOWED_HOST}`
end

httpProxy.OnServerInvoke = function(_player, url, method, headers, body)
	if not isUrlAllowed(url) then
		warn(`{prefix} blocked HTTP proxy request to a non-{ALLOWED_HOST} URL`)
		error(`FlipbookHttpProxy: requests are only permitted to {ALLOWED_HOST}`)
	end

	return HttpService:RequestAsync({
		Url = url,
		Method = method,
		Headers = headers,
		Body = body,
	})
end

print(`{prefix} successfully initialized in {os.clock() - startTime}s`)
