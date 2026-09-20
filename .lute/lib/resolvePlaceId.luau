local json = require("@std/json")
local net = require("@std/net")

export type Request = (url: string, metadata: net.Metadata?) -> net.Response

local function resolvePlaceId(universeId: number, placeName: string, apiKey: string, request: Request?): number
	local requestPlacePage: Request = request or net.request
	local cursor: string? = nil

	while true do
		local url = `https://develop.roblox.com/v1/universes/{universeId}/places?limit=100&isUniverseCreation=true`
		if cursor then
			local encodedCursor = cursor:gsub("[^%w%-%._~]", function(character)
				return string.format("%%%02X", string.byte(character))
			end)
			url ..= `&cursor={encodedCursor}`
		end

		local response = requestPlacePage(url, {
			method = "GET",
			headers = {
				["x-api-key"] = apiKey,
			},
		})
		if not response.ok then
			error(`Failed to list preview places ({response.status})`, 0)
		end

		local body = json.asObject(json.deserialize(response.body))
		assert(body, "Expected the place-list response to be a JSON object")

		local places = json.asArray(body.data)
		assert(places, "Expected the place-list response to contain a data array")
		for _, value in places do
			local place = json.asObject(value)
			if place and place.name == placeName and type(place.id) == "number" then
				return place.id
			end
		end

		cursor = if type(body.nextPageCursor) == "string" then body.nextPageCursor else nil
		if not cursor or cursor == "" then
			break
		end
	end

	error(`Could not find preview place {placeName}`, 0)
end

return resolvePlaceId
