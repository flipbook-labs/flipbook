local test = require("@std/test")

local requestGitHub = require("@scripts/lib/policy/requestGitHub")

test.suite("requestGitHub", function(suite)
	suite:case("runs gh api with the pinned API version", function(assert)
		local command
		local response = requestGitHub({ "repos/flipbook-labs/flipbook/rulesets" }, function(arguments)
			command = arguments
			return { ok = true, stdout = "  response\n", stderr = "" }
		end)

		assert.eq(response, "response")
		assert.eq(command[1], "gh")
		assert.eq(command[2], "api")
		assert.eq(command[4], "X-GitHub-Api-Version: 2026-03-10")
		assert.eq(command[5], "repos/flipbook-labs/flipbook/rulesets")
	end)

	suite:case("surfaces a trimmed GitHub CLI error", function(assert)
		assert.throwsWith("request failed", function()
			requestGitHub({}, function()
				return { ok = false, stdout = "", stderr = "  request failed\n" }
			end)
		end)
	end)
end)
