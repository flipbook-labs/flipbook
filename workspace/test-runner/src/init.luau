local Charm = require("@pkg/Charm")
local Jest = require("@pkg/Jest")

local function getRoots()
	local roots = {}
	for _, child in ipairs(script.Parent:GetChildren()) do
		if child:FindFirstChild("jest.config") then
			table.insert(roots, child)
		end
	end
	return roots
end

local function runTests()
	_G.__DEV__ = true
	_G.__ROACT_17_MOCK_SCHEDULER__ = true

	Charm.flags.strict = true
	Charm.flags.frozen = true

	local roots = getRoots()

	local status, result = Jest.runCLI(script.Parent, {
		verbose = false,
		ci = false,
		testPathPattern = _G.JEST_TEST_PATH_PATTERN,
	}, roots):awaitStatus()

	if status == "Rejected" then
		print(result)
	end

	if status ~= "Resolved" or result.results.numFailedTestSuites > 0 or result.results.numFailedTests > 0 then
		error(1)
	end
end

return {
	runTests = runTests,
}
