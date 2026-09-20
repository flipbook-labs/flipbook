local json = require("@std/json")
local net = require("@std/net")

export type Request = (url: string, metadata: net.Metadata?) -> net.Response

local function upsertPullRequestComment(
	repository: string,
	pullRequestNumber: number,
	githubToken: string,
	marker: string,
	body: string,
	request: Request?
)
	local sendRequest: Request = request or net.request
	local headers = {
		Accept = "application/vnd.github+json",
		Authorization = `Bearer {githubToken}`,
		["User-Agent"] = "Flipbook",
		["X-GitHub-Api-Version"] = "2022-11-28",
	}

	local function requestGitHub(url: string, method: string?, requestBody: string?): net.Response
		local requestHeaders = table.clone(headers)
		if requestBody then
			requestHeaders["Content-Type"] = "application/json"
		end

		local response = sendRequest(url, {
			body = requestBody,
			headers = requestHeaders,
			method = method or "GET",
		})
		if not response.ok then
			error(`GitHub API request failed ({response.status}) for {method or "GET"} {url}: {response.body}`, 0)
		end
		return response
	end

	local existingCommentId: number? = nil
	local page = 1
	while not existingCommentId do
		local response = requestGitHub(
			`https://api.github.com/repos/{repository}/issues/{pullRequestNumber}/comments?per_page=100&page={page}`
		)
		local comments = json.asArray(json.deserialize(response.body))
		assert(comments, "Expected the pull request comments response to be a JSON array")

		for _, value in comments do
			local comment = json.asObject(value)
			if
				comment
				and type(comment.body) == "string"
				and comment.body:sub(1, #marker) == marker
				and type(comment.id) == "number"
			then
				existingCommentId = comment.id
				break
			end
		end

		if #comments < 100 then
			break
		end
		page += 1
	end

	local payload = json.serialize({
		body = body,
	})
	if existingCommentId then
		requestGitHub(`https://api.github.com/repos/{repository}/issues/comments/{existingCommentId}`, "PATCH", payload)
	else
		requestGitHub(`https://api.github.com/repos/{repository}/issues/{pullRequestNumber}/comments`, "POST", payload)
	end
end

return upsertPullRequestComment
