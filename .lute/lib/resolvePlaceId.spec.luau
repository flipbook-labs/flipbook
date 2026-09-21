local json = require("@std/json")
local test = require("@std/test")

local resolvePlaceId = require("@scripts/lib/resolvePlaceId")

test.case("resolves a place across paginated results", function(asserts)
	local urls: { string } = {}
	local pages = {
		json.serialize({
			data = {
				{
					id = 123,
					name = "Another Preview",
				},
			},
			nextPageCursor = "next page",
		}),
		json.serialize({
			data = {
				{
					id = 456,
					name = "Flipbook Preview 654 Branch Flipbook",
				},
			},
			nextPageCursor = nil,
		}),
	}
	local requestIndex = 0

	local placeId = resolvePlaceId(
		10262009842,
		"Flipbook Preview 654 Branch Flipbook",
		"secret",
		function(url, metadata)
			requestIndex += 1
			table.insert(urls, url)
			asserts.eq("secret", if metadata and metadata.headers then metadata.headers["x-api-key"] else nil)

			return {
				body = pages[requestIndex],
				headers = {},
				ok = true,
				status = 200,
			}
		end
	)

	asserts.eq(456, placeId)
	asserts.eq(2, #urls)
	asserts.strContains(urls[2], "cursor=next%20page")
end)

test.case("rejects a failed place listing without exposing the API key", function(asserts)
	local ok, problem = pcall(function()
		resolvePlaceId(10262009842, "Flipbook Preview 654", "secret", function()
			return {
				body = "forbidden",
				headers = {},
				ok = false,
				status = 403,
			}
		end)
	end)

	asserts.eq(false, ok)
	asserts.strContains(tostring(problem), "Failed to list preview places (403)")
	asserts.strNotContains(tostring(problem), "secret")
end)
