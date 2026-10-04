local json = require("@std/json")

local sendAsync = require("@scripts/lib/posthog/sendAsync")

local function annotateAsync(apiKey: string, projectId: string, content: string, dryRun: boolean)
	sendAsync({
		url = `https://us.posthog.com/api/projects/{projectId}/annotations/`,
		metadata = {
			method = "POST",
			headers = {
				Authorization = `Bearer {apiKey}`,
				["Content-Type"] = "application/json",
			},
			body = json.serialize(json.object({
				content = content,
				date_marker = os.date("!%Y-%m-%dT%H:%M:%SZ"),
				scope = "project",
			})),
		},
	}, dryRun)
end

return annotateAsync
