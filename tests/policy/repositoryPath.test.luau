local test = require("@std/test")

local repositoryPath = require("@scripts/lib/policy/repositoryPath")

test.case("builds the GitHub repository API path", function(assert)
	assert.eq(
		repositoryPath({ repository = { owner = "flipbook-labs", name = "flipbook" } }),
		"repos/flipbook-labs/flipbook"
	)
end)
