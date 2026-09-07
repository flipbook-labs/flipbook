local HttpService = game:GetService("HttpService")

export type LaunchData = {
	search: string?,
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
