local json = require("@std/json")

local checkProjectTokenAsync = require("@scripts/lib/posthog/checkProjectTokenAsync")
local createUuidV5 = require("@scripts/lib/createUuidV5")
local sendAsync = require("@scripts/lib/posthog/sendAsync")
local types = require("@scripts/lib/posthog/types")

-- CI events share the product's PostHog project, so they use a fixed distinct
-- ID and the `ci_` event prefix to stay separable from user events.
local DISTINCT_ID = "github-actions"

-- Namespace for CI event UUIDs. Changing it changes every event's UUID.
local EVENT_NAMESPACE = "64441ae0-fde6-4d6a-9f94-765ed5f015ba"

local function captureAsync(token: string, event: types.Event, dryRun: boolean)
	checkProjectTokenAsync(token, dryRun)

	local properties = table.clone(event.properties)
	-- A fixed CI identity has no person behind it, so skip creating a profile.
	properties["$process_person_profile"] = false

	-- PostHog drops an event whose UUID, timestamp, name, and distinct ID all
	-- match one it already has. Deriving the UUID from the event and its commit
	-- makes re-running a job for the same commit safe.
	local uuid = createUuidV5(EVENT_NAMESPACE, `{event.name}:{event.commit}`)

	sendAsync({
		url = "https://us.i.posthog.com/i/v0/e/",
		metadata = {
			method = "POST",
			headers = { ["Content-Type"] = "application/json" },
			body = json.serialize(json.object({
				api_key = token,
				event = event.name,
				uuid = uuid,
				timestamp = event.timestamp,
				distinct_id = DISTINCT_ID,
				properties = json.object(properties),
			})),
		},
	}, dryRun)
end

return captureAsync
