local HttpService = game:GetService("HttpService")

export type LaunchData = {
	-- Prepopulates the sidebar search so preview viewers can find stories relevant to the pull request.
	search: string?,
	-- Opens a single story immediately by its sidebar-relative path when the pull request is focused on it.
	story: string?,
}

local function getLaunchData(launchData: unknown): LaunchData
	local result: LaunchData = {}

	if type(launchData) ~= "string" or launchData == "" then
		return result
	end

	local success, decoded = pcall(HttpService.JSONDecode, HttpService, launchData)
	if not success or type(decoded) ~= "table" then
		return result
	end

	if type(decoded.search) == "string" and decoded.search ~= "" then
		result.search = decoded.search
	end
	if type(decoded.story) == "string" and decoded.story ~= "" then
		result.story = decoded.story
	end

	return result
end

return getLaunchData
