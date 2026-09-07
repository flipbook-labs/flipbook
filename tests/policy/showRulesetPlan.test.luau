local test = require("@std/test")

local showRulesetPlan = require("@scripts/lib/policy/showRulesetPlan")

test.suite("showRulesetPlan", function(suite)
	suite:case("reports no drift without creating files", function(assert)
		local wroteFile = false
		local hasDrift = showRulesetPlan({ value = 1 }, { value = 1 }, {
			writeTemporaryJson = function()
				wroteFile = true
			end,
		})

		assert.eq(hasDrift, false)
		assert.eq(wroteFile, false)
	end)

	suite:case("renders drift through a temporary no-index diff", function(assert)
		local written = {}
		local removed = {}
		local command
		local options
		local hasDrift = showRulesetPlan({ value = 2 }, { value = 1 }, {
			writeTemporaryJson = function(name, value)
				written[name] = value
				return `/tmp/{name}.json`
			end,
			runProcess = function(arguments, runOptions)
				command = arguments
				options = runOptions
				return { ok = false }
			end,
			remove = function(filePath)
				table.insert(removed, tostring(filePath))
			end,
		})

		assert.eq(hasDrift, true)
		assert.eq(written.live.value, 1)
		assert.eq(written.desired.value, 2)
		assert.eq(command[1], "git")
		assert.eq(command[2], "diff")
		assert.eq(command[5], "/tmp/live.json")
		assert.eq(command[6], "/tmp/desired.json")
		assert.eq(options.stdio, "inherit")
		assert.eq(removed[1], "/tmp/live.json")
		assert.eq(removed[2], "/tmp/desired.json")
	end)
end)
