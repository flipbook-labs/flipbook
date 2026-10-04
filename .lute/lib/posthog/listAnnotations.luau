local types = require("@scripts/lib/posthog/types")

-- Fetches a single annotation, which confirms the personal API key and project
-- ID without writing anything.
local function listAnnotations(apiKey: string, projectId: string): types.Request
	return {
		url = `https://us.posthog.com/api/projects/{projectId}/annotations/?limit=1`,
		metadata = {
			method = "GET",
			headers = { Authorization = `Bearer {apiKey}` },
		},
	}
end

return listAnnotations
