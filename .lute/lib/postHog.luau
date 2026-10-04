local json = require("@std/json")
local net = require("@std/net")
local process = require("@std/process")

-- CI events share the product's PostHog project, so they use a fixed
-- distinct ID and the `ci_` event prefix to stay separable from user events.
local DISTINCT_ID = "github-actions"
local DEFAULT_INGEST_HOST = "https://us.i.posthog.com"
local DEFAULT_APP_HOST = "https://us.posthog.com"

export type Options = {
	-- Print each request instead of sending it.
	dryRun: boolean,
}

local function assertEnv(name: string): string
	local value = process.env[name]
	assert(value ~= nil and value ~= "", `{name} must be set`)
	return value
end

local function send(options: Options, url: string, headers: { [string]: string }, body: { [string]: json.Value })
	local encoded = json.serialize(json.object(body))
	if options.dryRun then
		print(`POST {url}\n{json.serialize(json.object(body), true)}`)
		return
	end

	headers["Content-Type"] = "application/json"
	local response = net.request(url, { method = "POST", headers = headers, body = encoded })
	if not response.ok then
		error(`PostHog request failed ({response.status}) for {url}: {response.body}`, 0)
	end
end

local function capture(options: Options, event: string, properties: { [string]: json.Value })
	local eventProperties = table.clone(properties)
	-- A fixed CI identity has no person behind it, so skip creating a profile.
	eventProperties["$process_person_profile"] = false

	local host = process.env.POSTHOG_HOST or DEFAULT_INGEST_HOST
	send(options, `{host}/i/v0/e/`, {}, {
		api_key = if options.dryRun then "<POSTHOG_PROJECT_TOKEN>" else assertEnv("POSTHOG_PROJECT_TOKEN"),
		event = event,
		distinct_id = DISTINCT_ID,
		properties = json.object(eventProperties),
	})
end

local function annotate(options: Options, content: string)
	local host = process.env.POSTHOG_APP_HOST or DEFAULT_APP_HOST
	local projectId = if options.dryRun then "<POSTHOG_PROJECT_ID>" else assertEnv("POSTHOG_PROJECT_ID")
	local apiKey = if options.dryRun then "<POSTHOG_PERSONAL_API_KEY>" else assertEnv("POSTHOG_PERSONAL_API_KEY")

	send(options, `{host}/api/projects/{projectId}/annotations/`, {
		Authorization = `Bearer {apiKey}`,
	}, {
		content = content,
		date_marker = os.date("!%Y-%m-%dT%H:%M:%SZ"),
		scope = "project",
	})
end

return {
	capture = capture,
	annotate = annotate,
}
