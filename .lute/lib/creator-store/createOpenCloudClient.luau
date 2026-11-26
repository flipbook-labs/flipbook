local OpenApiLuteTransport = require("@lpm/openapi-lute-transport@v0.1.0")
local OpenApiRuntime = require("@lpm/openapi-runtime@v0.1.0")

-- The client that the generated Open Cloud functions send their requests
-- through, signed with an Open Cloud API key.
local function createOpenCloudClient(apiKey: string): OpenApiRuntime.Client
	return OpenApiRuntime.createClient({
		baseUrl = "https://apis.roblox.com",
		transport = OpenApiLuteTransport,
		headers = {
			["x-api-key"] = apiKey,
		},
	})
end

return createOpenCloudClient
