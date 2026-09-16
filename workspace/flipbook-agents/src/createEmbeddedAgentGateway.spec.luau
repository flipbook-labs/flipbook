local JestGlobals = require("@pkg/JestGlobals")

local createAgentController = require("@root/createAgentController")
local createEmbeddedAgentGateway = require("@root/createEmbeddedAgentGateway")

local expect = JestGlobals.expect
local test = JestGlobals.test

test("publishes the embedded action manifest and cleans up", function()
	local parent = Instance.new("Folder")
	local controller = createAgentController(function() end)
	local cleanup = createEmbeddedAgentGateway(controller, parent)
	local gateway = parent:FindFirstChild("FlipbookAgentGateway") :: BindableFunction

	local response = gateway:Invoke({ method = "list" })
	local names = {}
	for _, action in response.result.actions do
		table.insert(names, action.name)
	end

	expect(names).toEqual({
		"listStorybooks",
		"listStories",
		"openStory",
		"getCurrentStory",
		"getControls",
		"setControls",
	})

	cleanup()
	expect(parent:FindFirstChild("FlipbookAgentGateway")).toBeNil()
end)
