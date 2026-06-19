local CollectionService = game:GetService("CollectionService")
local CoreGui = game:GetService("CoreGui")

local JestGlobals = require("@pkg/JestGlobals")

local constants = require("@root/Actions/constants")
local publishBindables = require("./BindableRegistry")
local types = require("@root/Actions/types")

local afterEach = JestGlobals.afterEach
local expect = JestGlobals.expect
local test = JestGlobals.test

local function makeRegistry(dispatch: ((id: string, payload: any) -> types.ActionResult)?): types.ActionRegistry
	return {
		actions = {
			{
				id = "Flipbook/Foo",
				text = "Foo",
				statusTip = "Foo tip",
				run = function()
					return nil
				end,
			},
		},
		dispatch = dispatch or function(id, payload)
			return { ok = true, result = { id = id, payload = payload } }
		end,
		manifest = function()
			return { { id = "Flipbook/Foo", text = "Foo", statusTip = "Foo tip" } }
		end,
	}
end

local cleanup: (() -> ())?

afterEach(function()
	if cleanup then
		cleanup()
		cleanup = nil
	end
	local existing = CoreGui:FindFirstChild(constants.FOLDER_NAME)
	if existing then
		existing:Destroy()
	end
end)

test("creates a tagged, attributed folder in CoreGui", function()
	cleanup = publishBindables(makeRegistry())

	local folder = CoreGui:FindFirstChild(constants.FOLDER_NAME) :: Folder
	expect(folder).never.toBeNil()
	expect(folder:GetAttribute("ProtocolVersion")).toBe(constants.PROTOCOL_VERSION)

	local bindable = folder:FindFirstChild("Flipbook/Foo") :: BindableFunction
	expect(bindable).never.toBeNil()
	expect(bindable:GetAttribute("Text")).toBe("Foo")
	expect(bindable:GetAttribute("StatusTip")).toBe("Foo tip")
	expect(CollectionService:HasTag(bindable, constants.TAG)).toBe(true)
end)

test("routes invocations through dispatch", function()
	cleanup = publishBindables(makeRegistry())

	local folder = CoreGui:FindFirstChild(constants.FOLDER_NAME) :: Folder
	local bindable = folder:FindFirstChild("Flipbook/Foo") :: BindableFunction
	local result = bindable:Invoke({ hello = "world" })

	expect(result.ok).toBe(true)
	expect(result.result.id).toBe("Flipbook/Foo")
	expect(result.result.payload.hello).toBe("world")
end)

test("exposes a manifest endpoint", function()
	cleanup = publishBindables(makeRegistry())

	local folder = CoreGui:FindFirstChild(constants.FOLDER_NAME) :: Folder
	local manifestBindable = folder:FindFirstChild(constants.MANIFEST_NAME) :: BindableFunction
	local manifest = manifestBindable:Invoke()

	expect(#manifest).toBe(1)
	expect(manifest[1].id).toBe("Flipbook/Foo")
end)

test("destroys any pre-existing folder", function()
	local stale = Instance.new("Folder")
	stale.Name = constants.FOLDER_NAME
	stale.Parent = CoreGui

	cleanup = publishBindables(makeRegistry())

	local count = 0
	for _, child in CoreGui:GetChildren() do
		if child.Name == constants.FOLDER_NAME then
			count += 1
		end
	end
	expect(count).toBe(1)
	expect(stale.Parent).toBeNil()
end)

test("cleanup removes the folder", function()
	local localCleanup = publishBindables(makeRegistry())
	localCleanup()
	expect(CoreGui:FindFirstChild(constants.FOLDER_NAME)).toBeNil()
end)
