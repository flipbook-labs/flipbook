local Jest = require("@pkg/Jest")

local function runTests()
	local root = script.Parent["flipbook-core"]

	_G.__DEV__ = true
	_G.__ROACT_17_MOCK_SCHEDULER__ = true

	local status, result = Jest.runCLI(root, {
		verbose = false,
		ci = false,
	}, { root }):awaitStatus()

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
