local json = require("@std/json")

local types = require("@scripts/lib/posthog/types")

local function annotate(apiKey: string, projectId: string, content: string): types.Request
	return {
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
	}
end

return annotate
