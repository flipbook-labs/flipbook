local ModuleLoader = require(script.Packages.ModuleLoader)

if plugin then
	local loader = ModuleLoader.new()

	local action = plugin:CreatePluginAction(
		"run-tests",
		"Run tests",
		"Runs all unit tests in the experience with plugin-level security."
	)

	action.Triggered:Connect(function()
		loader:load(script.runTests)
		loader:clear()
	end)
else
	require(script.runTests)
end
