local PluginDebugService = game:GetService("PluginDebugService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local TestEZ = require(script.Parent.DevPackages.TestEZ)

local function getTestRoot()
	if script:IsDescendantOf(ServerScriptService) then
		return ReplicatedStorage.RoactStorybook
	else
		return PluginDebugService["user_RoactStorybook.rbxm"].RoactStorybook
	end
end

local testRoot = getTestRoot()

local function runTests()
	local roots = {}
	for _, child in ipairs(testRoot:GetChildren()) do
		-- Skip over third-party packages
		if child.Name == "Packages" then
			continue
		end

		table.insert(roots, child)
	end

	local results = TestEZ.TestBootstrap:run(roots)

	if results.failureCount > 0 then
		print("❌ Test run failed")
	else
		print("✔️ All tests passed")
	end
end

runTests()

return nil
