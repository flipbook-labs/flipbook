local json = require("@std/json")
local net = require("@std/net")

-- A request to PostHog, built separately from sending it so a dry run can
-- print it instead.
export type Request = {
	url: string,
	metadata: net.Metadata,
}

export type Event = {
	name: string,
	-- The full commit SHA the event reports.
	commit: string,
	-- ISO 8601. Fixed per commit so a re-run matches the first send.
	timestamp: string,
	properties: { [string]: json.Value },
}

return nil
