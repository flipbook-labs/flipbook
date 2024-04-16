local ServerScriptService = game:GetService("ServerScriptService")

local flipbook = script:FindFirstAncestor("flipbook") or ServerScriptService:FindFirstChild("flipbook")

local TestEZ = require(flipbook.Packages.TestEZ)

_G.__DEV__ = true
_G.__ROACT_17_MOCK_SCHEDULER__ = true

-- Prune any tests that we don't own
for _, descendant in ipairs(flipbook.Packages:GetDescendants()) do
	if descendant.Name:match("%.spec$") then
		descendant:Destroy()
	end
end

local results = TestEZ.TestBootstrap:run({
	flipbook,
}, TestEZ.Reporters.TextReporterQuiet)

local success = results.failureCount == 0

if success then
	print("✔️ All tests passed")
else
	print("❌ Test run failed")
end
