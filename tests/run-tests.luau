local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Jest = require(ReplicatedStorage.Packages.Jest)

local processServiceExists, ProcessService = pcall(function()
	-- selene: allow(incorrect_standard_library_use)
	return game:GetService("ProcessService")
end)

local root = ReplicatedStorage.Flipbook

_G.__DEV__ = true
_G.__ROACT_17_MOCK_SCHEDULER__ = true

local status, result = Jest.runCLI(root, {
	verbose = false,
	ci = false,
}, { root }):awaitStatus()

if status == "Rejected" then
	print(result)
end

if status == "Resolved" and result.results.numFailedTestSuites == 0 and result.results.numFailedTests == 0 then
	if processServiceExists then
		ProcessService:ExitAsync(0)
	end
end

if processServiceExists then
	ProcessService:ExitAsync(1)
end

return nil
