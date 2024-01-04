local flipbook = script:FindFirstAncestor("flipbook")

local types = require(flipbook.Renderers.types)

type Renderer = types.Renderer

local function createRobloxRenderer(): Renderer
	local handle

	local function mount(target, element)
		if typeof(element) == "Instance" and element:IsA("GuiObject") then
			element.Parent = target
			handle = element
		end
		return element
	end

	local function unmount()
		if handle then
			handle:Destroy()
		end
	end

	return {
		mount = mount,
		unmount = unmount,
	}
end

return createRobloxRenderer
