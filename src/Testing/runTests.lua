local ServerScriptService = game:GetService("ServerScriptService")

local flipbook = script:FindFirstAncestor("flipbook") or ServerScriptService:FindFirstChild("flipbook")

local TestEZ = require(flipbook.Packages.TestEZ)
local withGlobals = require(flipbook.Testing.withGlobals)

local function pruneThirdPartyTests(testRoot: Instance)
	local tests: { ModuleScript } = {}
	local thirdPartyInstances = {}

	for _, descendant in ipairs(testRoot:GetDescendants()) do
		-- Include conditions for any third-party modules here
		if descendant.Name == "Packages" then
			table.insert(thirdPartyInstances, descendant)
		end

		if descendant.Name:match("%.spec$") then
			table.insert(tests, descendant)
		end
	end

	for _, test in tests do
		for _, thirdPartyInstance in thirdPartyInstances do
			if test:IsDescendantOf(thirdPartyInstance) then
				test:Destroy()
			end
		end
	end
end

local function runTests(testRoot: Instance): string
	-- Prune any tests that we don't own
	pruneThirdPartyTests(testRoot)

	local cleanup = withGlobals({
		__DEV__ = true,
		__ROACT_17_MOCK_SCHEDULER__ = true,
	})

	local results = TestEZ.TestBootstrap:run({
		flipbook,
	}, TestEZ.Reporters.TextReporterQuiet)

	local success = results.failureCount == 0

	cleanup()

	if success then
		return "✔️ All tests passed"
	else
		return "❌ Test run failed"
	end
end

return runTests
