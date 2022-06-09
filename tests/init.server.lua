local ReplicatedStorage = game:GetService("ReplicatedStorage")

local runTests = require(ReplicatedStorage.flipbook.TestHelpers.runTests)

local success = runTests()

if success then
	print("✔️ All tests passed")
else
	print("❌ Test run failed")
end
