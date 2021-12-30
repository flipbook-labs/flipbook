local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TestEZ = require(ReplicatedStorage.DevPackages.TestEZ)

local roots = {}
for _, child in ipairs(ReplicatedStorage.RoactStorybook:GetChildren()) do
	if child.Name ~= "Packages" then
		table.insert(roots, child)
	end
end

local results = TestEZ.TestBootstrap:run(roots)

if results.failureCount > 0 then
	print("❌ Test run failed")
else
	print("✔️ All tests passed")
end
