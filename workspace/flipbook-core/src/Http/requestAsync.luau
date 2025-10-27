local HttpService = game:GetService("HttpService")

local Sift = require("@pkg/Sift")
local logging = require("@root/logging")

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

	logging.debug(`{requestOptions.method} {url}`)
	local res
	local success, err = pcall(function()
		res = HttpService:RequestAsync({
			Url = url,
			Method = requestOptions.method,
			Headers = requestOptions.headers,
			Body = body,
		})
	end)

	if not success then
		logging.warn("failed to communicate with backend:", err)
	end
	if res and not res.Success then
		logging.warn("failed sending event to backend:", res.StatusMessage)
	end

	return res
end

return requestAsync
