local types = require("@root/Renderers/types")

type Renderer = types.Renderer

local function createRobloxRenderer(): Renderer
	local handle: GuiObject?
	local currentElement

	local function mount(container, element, context)
		currentElement = element

		if typeof(element) == "function" then
			local args = if context and context.args then context.args else {}
			element = element(args)
		end

		if typeof(element) == "Instance" and element:IsA("GuiObject") then
			handle = element
			element.Parent = container
		end
	end

	local function unmount()
		if handle then
			handle:Destroy()
		end
	end

	local function update(context)
		if handle then
			local container = handle.Parent
			unmount()
			mount(container, currentElement, context)
		end
	end

	return {
		mount = mount,
		update = update,
		unmount = unmount,
	}
end

return createRobloxRenderer
