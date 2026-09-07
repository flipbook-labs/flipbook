local fs = require("@std/fs")
local json = require("@std/json")
local process = require("@std/process")

local writeTemporaryJson = require("@scripts/lib/policy/ruleset/writeTemporaryJson")

local function showRulesetPlan(desired: any, live: any): boolean
	if json.serialize(desired) == json.serialize(live) then
		print("Ruleset is in sync.")
		return false
	end

	local livePath = writeTemporaryJson("live", live)
	local desiredPath = writeTemporaryJson("desired", desired)
	print("Ruleset drift detected:")
	process.run({ "git", "diff", "--no-index", "--", tostring(livePath), tostring(desiredPath) }, {
		stdio = "inherit",
	})
	fs.remove(livePath)
	fs.remove(desiredPath)
	return true
end

return showRulesetPlan
