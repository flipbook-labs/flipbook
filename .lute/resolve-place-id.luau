local process = require("@std/process")

local resolvePlaceId = require("@scripts/lib/resolvePlaceId")

-- The Storybook deploy job has Lute from Rokit but never runs `lute run install`,
-- so this script uses only the standard library.
local USAGE = "Usage: lute run resolve-place-id <universe-id> <place-name>"

local _, universeIdValue, placeName = ...

if universeIdValue == "--help" then
	print(USAGE)
	print("")
	print("Prints the ID of the place with that name. Reads the API key from ROBLOX_API_KEY.")
	return
end

if universeIdValue == nil or placeName == nil then
	print(USAGE)
	process.exit(1)
end

local universeId = assert(tonumber(universeIdValue), `The universe ID must be a number, got "{universeIdValue}"`)
local apiKey = assert(process.env.ROBLOX_API_KEY, "ROBLOX_API_KEY is required")

print(resolvePlaceId(universeId, placeName, apiKey))
