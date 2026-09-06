local HttpService = game:GetService("HttpService")

local function getSearchTermFromLaunchData(launchData: unknown): string?
	if type(launchData) ~= "string" or launchData == "" then
		return nil
	end

	local success, decoded = pcall(HttpService.JSONDecode, HttpService, launchData)
	if not success or type(decoded) ~= "table" or type(decoded.search) ~= "string" or decoded.search == "" then
		return nil
	end

	return decoded.search
end

return getSearchTermFromLaunchData
