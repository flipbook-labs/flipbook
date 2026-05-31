local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- This path comes from the tests project generated in `.lute/test.luau`
local TestRunner = (require :: any)(ReplicatedStorage.Flipbook.workspace["test-runner"])

TestRunner.runTests()

return nil
