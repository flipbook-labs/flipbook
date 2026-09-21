local json = require("@std/json")
local net = require("@std/net")
local test = require("@std/test")

local upsertPullRequestComment = require("@scripts/lib/upsertPullRequestComment")

local MARKER = "<!-- flipbook-pr-preview -->"

type CapturedRequest = {
	metadata: net.Metadata,
	url: string,
}

test.case("updates the marked comment across paginated results", function(asserts)
	local requests: { CapturedRequest } = {}
	local firstPage: json.Array = {}
	for index = 1, 100 do
		table.insert(
			firstPage,
			{
				body = `Unrelated comment {index}`,
				id = index,
			} :: json.Object
		)
	end
	local secondPage: json.Array = {
		{
			body = `{MARKER}\nOld`,
			id = 456,
		} :: json.Object,
	}

	upsertPullRequestComment(
		"flipbook-labs/flipbook",
		638,
		"secret",
		MARKER,
		`{MARKER}\nUpdated`,
		function(url, metadata)
			local requestMetadata = assert(metadata, "Expected GitHub request metadata")
			table.insert(requests, {
				metadata = requestMetadata,
				url = url,
			})

			if #requests == 1 then
				return {
					body = json.serialize(firstPage),
					headers = {},
					ok = true,
					status = 200,
				}
			elseif #requests == 2 then
				return {
					body = json.serialize(secondPage),
					headers = {},
					ok = true,
					status = 200,
				}
			end

			return {
				body = "",
				headers = {},
				ok = true,
				status = 200,
			}
		end
	)

	asserts.eq(3, #requests)
	asserts.strContains(requests[2].url, "page=2")
	local updateMetadata = requests[3].metadata
	asserts.eq("PATCH", updateMetadata.method)
	asserts.strContains(requests[3].url, "/issues/comments/456")
	asserts.strContains(assert(updateMetadata.body, "Expected update request body"), "Updated")
	asserts.eq("Bearer secret", assert(updateMetadata.headers, "Expected update request headers").Authorization)
end)

test.case("creates a marked comment when none exists", function(asserts)
	local requests: { CapturedRequest } = {}

	upsertPullRequestComment(
		"flipbook-labs/flipbook",
		638,
		"secret",
		MARKER,
		`{MARKER}\nCreated`,
		function(url, metadata)
			local requestMetadata = assert(metadata, "Expected GitHub request metadata")
			table.insert(requests, {
				metadata = requestMetadata,
				url = url,
			})

			return {
				body = if #requests == 1 then "[]" else "",
				headers = {},
				ok = true,
				status = if #requests == 1 then 200 else 201,
			}
		end
	)

	asserts.eq(2, #requests)
	local createMetadata = requests[2].metadata
	asserts.eq("POST", createMetadata.method)
	asserts.strContains(requests[2].url, "/issues/638/comments")
	asserts.strContains(assert(createMetadata.body, "Expected create request body"), "Created")
end)
