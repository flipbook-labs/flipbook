local fs = require("@std/fs")
local path = require("@std/path")
local system = require("@std/system")
local test = require("@std/test")

local readRulesetConfig = require("@scripts/lib/policy/readRulesetConfig")

test.suite("readRulesetConfig", function(suite)
	suite:case("validates the checked-in repository policy", function(assert)
		local config = readRulesetConfig()

		assert.eq(config.repository.owner, "flipbook-labs")
		assert.that(#config.reviewers > 0)
		assert.that(#config.requiredChecks > 0)
	end)

	suite:case("rejects an invalid repository policy", function(assert)
		local configPath = path.join(system.tmpdir(), `flipbook-invalid-policy-{math.random(0, 0xffffff)}.json`)
		fs.writeStringToFile(configPath, '{"repository":{}}')

		assert.throwsWith("repository.owner must be a string", function()
			readRulesetConfig(configPath)
		end)
		fs.remove(configPath)
	end)
end)
