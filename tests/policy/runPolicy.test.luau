local test = require("@std/test")

local createRulesetConfig = require("./createRulesetConfig")
local runPolicy = require("@scripts/lib/policy/runPolicy")

local function failIfCalled(name: string): () -> ()
	return function()
		error(`unexpected {name} call`)
	end
end

test.suite("runPolicy", function(suite)
	suite:case("validates config without accessing GitHub", function(assert)
		local result = runPolicy({ "validate" }, {
			readRulesetConfig = createRulesetConfig,
			findRuleset = failIfCalled("findRuleset"),
		})

		assert.eq(result.action, "validate")
		assert.eq(result.hasDrift, false)
		assert.eq(result.applied, false)
	end)

	suite:case("plans with read-only dependencies and never updates", function(assert)
		local calls = {}
		local result = runPolicy({ "plan" }, {
			readRulesetConfig = createRulesetConfig,
			findRuleset = function()
				table.insert(calls, "find")
				return { id = 17 }
			end,
			buildRulesetPayload = function()
				table.insert(calls, "build")
				return { desired = true }
			end,
			fetchRuleset = function()
				table.insert(calls, "fetch")
				return { live = true }
			end,
			normalizeRuleset = function(live)
				table.insert(calls, "normalize")
				return live
			end,
			showRulesetPlan = function(desired, live)
				table.insert(calls, "show")
				assert.eq(desired.desired, true)
				assert.eq(live.live, true)
				return true
			end,
			updateRuleset = failIfCalled("updateRuleset"),
			writeTemporaryJson = failIfCalled("writeTemporaryJson"),
		})

		assert.eq(table.concat(calls, ","), "find,build,fetch,normalize,show")
		assert.eq(result.action, "plan")
		assert.eq(result.hasDrift, true)
		assert.eq(result.applied, false)
	end)

	suite:case("refuses apply without confirmation before reading config", function(assert)
		assert.throwsWith("refusing to apply without --confirm", function()
			runPolicy({ "apply" }, {
				readRulesetConfig = failIfCalled("readRulesetConfig"),
			})
		end)
	end)

	suite:case("applies drift only after explicit confirmation", function(assert)
		local updateArguments
		local removedPath
		local result = runPolicy({ "apply", "--confirm" }, {
			readRulesetConfig = createRulesetConfig,
			findRuleset = function()
				return { id = 17 }
			end,
			buildRulesetPayload = function()
				return { desired = true }
			end,
			fetchRuleset = function()
				return { live = true }
			end,
			normalizeRuleset = function(live)
				return live
			end,
			showRulesetPlan = function()
				return true
			end,
			writeTemporaryJson = function(name, value)
				assert.eq(name, "apply")
				assert.eq(value.desired, true)
				return "/tmp/apply.json"
			end,
			updateRuleset = function(_, rulesetId, payloadPath)
				updateArguments = { rulesetId, payloadPath }
			end,
			remove = function(filePath)
				removedPath = tostring(filePath)
			end,
		})

		assert.eq(updateArguments[1], 17)
		assert.eq(updateArguments[2], "/tmp/apply.json")
		assert.eq(removedPath, "/tmp/apply.json")
		assert.eq(result.applied, true)
	end)
end)
