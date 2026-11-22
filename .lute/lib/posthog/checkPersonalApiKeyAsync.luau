local sendAsync = require("@scripts/lib/posthog/sendAsync")

-- Fetches a single annotation, which confirms the personal API key and project
-- ID without writing anything.
local function checkPersonalApiKeyAsync(apiKey: string, projectId: string, dryRun: boolean)
	sendAsync({
		url = `https://us.posthog.com/api/projects/{projectId}/annotations/?limit=1`,
		metadata = {
			method = "GET",
			headers = { Authorization = `Bearer {apiKey}` },
		},
	}, dryRun)
end

return checkPersonalApiKeyAsync
