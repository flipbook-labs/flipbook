local json = require("@std/json")
local net = require("@std/net")

local function getUniverseStartPlaceAsync(universeId: number, apiKey: string): number
	local res = net.request(`https://develop.roblox.com/v1/universes/{universeId}/places`, {
		method = "GET",
		headers = {
			["x-api-key"] = apiKey,
		},
	})

	if res.status >= 400 then
		error(`failed to fetch start place for universe {universeId} ({res.status}): {res.body}`)
	end

	local body: any = json.deserialize(res.body)

	-- We choose the first place in the list and assume that's the start place.
	-- We really just need a placeId to use as the base for Luau Execution.
	-- This placeId won't get directly written to, just used as the task host.
	if type(body) == "table" and type(body.data) == "table" then
		local data = body.data :: json.Array
		if #data > 0 then
			local first = data[1] :: json.Object
			local id = first.id
			if type(id) == "number" then
				return id
			end
		end
	end

	error(`failed to find the start place for universe {universeId}`)
end

return getUniverseStartPlaceAsync
