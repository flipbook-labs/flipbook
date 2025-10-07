local Root = script.Parent.LuaChalkTestModel

local TestEZ = require(Root.Packages.Dev.TestEZ)

-- Run all tests, collect results, and report to stdout.
TestEZ.TestBootstrap:run(
	{ Root.LuaChalk },
	TestEZ.Reporters.TextReporter
)