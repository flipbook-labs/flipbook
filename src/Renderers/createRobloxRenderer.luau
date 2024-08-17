local types = require("@root/Renderers/types")

type Renderer = types.Renderer

local function createRobloxRenderer(): Renderer
	local handle

	local function mount(container, element, context)
		if typeof(element) == "function" then
			element = element(context.args)
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

	return {
		mount = mount,
		unmount = unmount,
	}
end

return createRobloxRenderer
