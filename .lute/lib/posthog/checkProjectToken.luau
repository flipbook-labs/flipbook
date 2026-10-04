local json = require("@std/json")

local types = require("@scripts/lib/posthog/types")

-- The capture endpoint answers 200 even for an invalid project token, so the
-- token is checked against the flags endpoint, which rejects one.
local function checkProjectToken(token: string): types.Request
	return {
		url = "https://us.i.posthog.com/flags?v=2",
		metadata = {
			method = "POST",
			headers = { ["Content-Type"] = "application/json" },
			body = json.serialize(json.object({
				api_key = token,
				distinct_id = "github-actions",
			})),
		},
	}
end

return checkProjectToken
