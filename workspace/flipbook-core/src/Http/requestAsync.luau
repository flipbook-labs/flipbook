local HttpService = game:GetService("HttpService")

local Sift = require("@pkg/Sift")

local function requestAsync(
	url: string,
	options: {
		method: string?,
		headers: { [string]: string | number | boolean }?,
		body: { [any]: any }?,
	}?
)
	local requestOptions = Sift.Dictionary.join({
		method = "GET",
		headers = {},
	}, options)

	local body
	if requestOptions and requestOptions.body then
		if typeof(requestOptions.body) == "table" then
			requestOptions.headers["Content-Type"] = "application/json"
			body = HttpService:JSONEncode(requestOptions.body)
		else
			body = tostring(requestOptions.body)
		end
	end

	local res
	local _success, _err = pcall(function()
		res = HttpService:RequestAsync({
			Url = url,
			Method = requestOptions.method,
			Headers = requestOptions.headers,
			Body = body,
		})
	end)

	-- TODO: Introduce a logging library so we can include these messages
	-- without printing to the output all the time
	-- if not success then
	-- 	warn("failed to communicate with backend:", err)
	-- end
	-- if res and not res.Success then
	-- 	warn("failed sending event to basckend:", res.StatusMessage)
	-- end

	return res
end

return requestAsync
