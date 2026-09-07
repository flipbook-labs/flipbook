local fs = require("@std/fs")
local json = require("@std/json")
local process = require("@std/process")

local writeTemporaryJson = require("@scripts/lib/policy/writeTemporaryJson")

local function showRulesetPlan(desired: any, live: any, dependencies: any?): boolean
	local deps = dependencies or {}
	local writeJson = deps.writeTemporaryJson or writeTemporaryJson
	local runProcess = deps.runProcess or process.run
	local remove = deps.remove or fs.remove

	if json.serialize(desired) == json.serialize(live) then
		print("Ruleset is in sync.")
		return false
	end

	local livePath = writeJson("live", live)
	local desiredPath = writeJson("desired", desired)
	print("Ruleset drift detected:")
	runProcess({ "git", "diff", "--no-index", "--", tostring(livePath), tostring(desiredPath) }, {
		stdio = "inherit",
	})
	remove(livePath)
	remove(desiredPath)
	return true
end

return showRulesetPlan
