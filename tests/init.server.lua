local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TestEZ = require(ReplicatedStorage.Packages.TestEZ)

for _, descendant in ipairs(ReplicatedStorage.flipbook.Packages:GetDescendants()) do
	if descendant.Name:match("%.spec$") then
		descendant:Destroy()
	end
end

local results = TestEZ.TestBootstrap:run({
	ReplicatedStorage.flipbook,
})

if results.failureCount > 0 then
	print("❌ Test run failed")
else
	print("✔️ All tests passed")
end
