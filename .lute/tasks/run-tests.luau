local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- This path comes from the tests place built in `.lute/test.luau`
local TestRunner = (require :: unknown)(ReplicatedStorage.Flipbook.workspace["test-runner"])

TestRunner.runTests()

return nil
