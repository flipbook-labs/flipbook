local JestGlobals = require("@pkg/JestGlobals")
local types = require("@root/Renderers/types")

local describe = JestGlobals.describe
local test = JestGlobals.test
local expect = JestGlobals.expect

type Renderer = types.Renderer

describe.each({
	{ "Fusion", require("./createFusionRenderer") },
	{ "React", require("./createReactRenderer") },
	{ "Roact", require("./createRoactRenderer") },
	{ "Roblox", require("./createRobloxRenderer") },
})("%s renderer", function(_name, createRenderer: Renderer)
	test("mount", function() end)

	test("unmount", function() end)

	test("update on arg changes", function() end)
end)
