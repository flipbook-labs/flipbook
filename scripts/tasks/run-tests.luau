--!nonstrict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- This path is defined in tests.project.json
local TestRunner = (require :: any)(ReplicatedStorage.Flipbook.workspace["test-runner"])

TestRunner.runTests()

return nil
