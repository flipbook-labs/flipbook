local json = require("@std/json")
local net = require("@std/net")
local process = require("@std/process")

-- CI events share the product's PostHog project, so they use a fixed
-- distinct ID and the `ci_` event prefix to stay separable from user events.
local DISTINCT_ID = "github-actions"
local DEFAULT_INGEST_HOST = "https://us.i.posthog.com"
local DEFAULT_APP_HOST = "https://us.posthog.com"

-- Where CI reads each value from, so failures name what to fix.
local SOURCES: { [string]: string } = {
	POSTHOG_PROJECT_TOKEN = "project-token",
	POSTHOG_PERSONAL_API_KEY = "personal-api-key",
	POSTHOG_PROJECT_ID = "project-id",
}
local ITEM = "op://Flipbook Edge/flipbook-posthog-ci"

export type Options = {
	-- Print each request instead of sending it.
	dryRun: boolean,
}

local function readSecret(options: Options, name: string): string
	if options.dryRun then
		return `<{name}>`
	end

	local value = process.env[name]
	assert(value ~= nil and value ~= "", `{name} is not set. CI resolves it from {ITEM}/{SOURCES[name]}.`)
	return value
end

local function describeFailure(name: string, response: net.Response): string
	local field = `{ITEM}/{SOURCES[name]}`
	if response.status == 401 then
		return `PostHog rejected {name}. Replace it in {field}, then re-run the PostHog check workflow.`
	elseif response.status == 403 then
		return `{name} is missing a scope this request needs. Update the key's scopes in PostHog.`
	elseif response.status == 404 then
		return `PostHog has no project at this ID and host. Check {ITEM}/project-id, and set POSTHOG_APP_HOST if the project is on the EU cloud.`
	end
	return `PostHog returned {response.status}.`
end

local function request(
	options: Options,
	method: string,
	url: string,
	headers: { [string]: string },
	body: json.Object?
): net.Response?
	local encoded = if body then json.serialize(body) else nil
	if options.dryRun then
		print(`{method} {url}`)
		if body then
			print(json.serialize(body, true))
		end
		return nil
	end

	if encoded then
		headers["Content-Type"] = "application/json"
	end
	return net.request(url, { method = method, headers = headers, body = encoded })
end

local function expectOk(name: string, response: net.Response?)
	if response and not response.ok then
		error(`{describeFailure(name, response)}\n{response.body}`, 0)
	end
end

-- The capture endpoint answers 200 even for an invalid project token, so the
-- token is checked against the flags endpoint, which rejects one.
local function checkProjectToken(options: Options)
	local host = process.env.POSTHOG_HOST or DEFAULT_INGEST_HOST
	local response = request(
		options,
		"POST",
		`{host}/flags?v=2`,
		{},
		json.object({
			api_key = readSecret(options, "POSTHOG_PROJECT_TOKEN"),
			distinct_id = DISTINCT_ID,
		})
	)
	expectOk("POSTHOG_PROJECT_TOKEN", response)
end

-- Reading annotations needs the key's annotation:read scope alongside the
-- annotation:write scope that creating one needs.
local function checkPersonalApiKey(options: Options)
	local host = process.env.POSTHOG_APP_HOST or DEFAULT_APP_HOST
	local projectId = readSecret(options, "POSTHOG_PROJECT_ID")
	local response = request(options, "GET", `{host}/api/projects/{projectId}/annotations/?limit=1`, {
		Authorization = `Bearer {readSecret(options, "POSTHOG_PERSONAL_API_KEY")}`,
	})
	expectOk("POSTHOG_PERSONAL_API_KEY", response)
end

local function capture(options: Options, event: string, properties: { [string]: json.Value })
	checkProjectToken(options)

	local eventProperties = table.clone(properties)
	-- A fixed CI identity has no person behind it, so skip creating a profile.
	eventProperties["$process_person_profile"] = false

	local host = process.env.POSTHOG_HOST or DEFAULT_INGEST_HOST
	local response = request(
		options,
		"POST",
		`{host}/i/v0/e/`,
		{},
		json.object({
			api_key = readSecret(options, "POSTHOG_PROJECT_TOKEN"),
			event = event,
			distinct_id = DISTINCT_ID,
			properties = json.object(eventProperties),
		})
	)
	expectOk("POSTHOG_PROJECT_TOKEN", response)
end

local function annotate(options: Options, content: string)
	local host = process.env.POSTHOG_APP_HOST or DEFAULT_APP_HOST
	local projectId = readSecret(options, "POSTHOG_PROJECT_ID")
	local response = request(
		options,
		"POST",
		`{host}/api/projects/{projectId}/annotations/`,
		{
			Authorization = `Bearer {readSecret(options, "POSTHOG_PERSONAL_API_KEY")}`,
		},
		json.object({
			content = content,
			date_marker = os.date("!%Y-%m-%dT%H:%M:%SZ"),
			scope = "project",
		})
	)
	expectOk("POSTHOG_PERSONAL_API_KEY", response)
end

return {
	capture = capture,
	annotate = annotate,
	checkProjectToken = checkProjectToken,
	checkPersonalApiKey = checkPersonalApiKey,
}
