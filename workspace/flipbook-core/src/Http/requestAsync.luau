local HttpService = game:GetService("HttpService")

local Sift = require("@pkg/Sift")
local logger = require("@root/logger")

type Response = {
	Success: boolean,
	StatusCode: number,
	StatusMessage: string,
	Headers: { [string]: string },
	Body: string,
}

local function requestAsync(
	url: string,
	options: {
		method: string?,
		headers: { [string]: string | number | boolean }?,
		body: unknown?,
	}?
)
	local requestOptions = Sift.Dictionary.join({
		method = "GET",
		headers = {},
	}, options)

	local body: string?
	if requestOptions and requestOptions.body then
		if typeof(requestOptions.body) == "table" then
			requestOptions.headers["Content-Type"] = "application/json"
			body = HttpService:JSONEncode(requestOptions.body)
		else
			body = tostring(requestOptions.body)
		end
	end

	logger.debug(`{requestOptions.method} {url}`)
	local res: Response?
	local success, err = pcall(function()
		res = HttpService:RequestAsync({
			Url = url,
			Method = requestOptions.method,
			Headers = requestOptions.headers,
			Body = body,
		})
	end)

	if not success then
		logger.warn("failed to communicate with backend:", err)
	end
	if res and not res.Success then
		logger.warn("failed sending event to backend:", res.StatusMessage)
	end

	return res
end

return requestAsync
