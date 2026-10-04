local json = require("@std/json")

local checkProjectTokenAsync = require("@scripts/lib/posthog/checkProjectTokenAsync")
local sendAsync = require("@scripts/lib/posthog/sendAsync")
local types = require("@scripts/lib/posthog/types")

-- CI events share the product's PostHog project, so they use a fixed distinct
-- ID and the `ci_` event prefix to stay separable from user events.
local DISTINCT_ID = "github-actions"

local function captureAsync(token: string, event: types.Event, dryRun: boolean)
	checkProjectTokenAsync(token, dryRun)

	local properties = table.clone(event.properties)
	-- A fixed CI identity has no person behind it, so skip creating a profile.
	properties["$process_person_profile"] = false

	sendAsync({
		url = "https://us.i.posthog.com/i/v0/e/",
		metadata = {
			method = "POST",
			headers = { ["Content-Type"] = "application/json" },
			body = json.serialize(json.object({
				api_key = token,
				event = event.name,
				distinct_id = DISTINCT_ID,
				properties = json.object(properties),
			})),
		},
	}, dryRun)
end

return captureAsync
