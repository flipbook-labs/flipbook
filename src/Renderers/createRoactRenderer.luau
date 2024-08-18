local types = require("@root/Renderers/types")

type Renderer = types.Renderer

type Packages = {
	Roact: any,
}

local function createRoactRenderer(packages: Packages): Renderer
	local Roact = packages.Roact
	local tree
	local currentElement

	local function mount(container, element, context)
		local props = if context then context.args else nil
		currentElement = element
		local renderedElement = Roact.createElement(element, props)
		tree = Roact.mount(renderedElement, container, "RoactRenderer")
	end

	local function update(context)
		if tree and currentElement then
			local props = if context then context.args else nil
			local element = Roact.createElement(currentElement, props)
			Roact.update(tree, element)
		end
	end

	local function unmount()
		if tree then
			Roact.unmount(tree)
		end
	end

	return {
		mount = mount,
		update = update,
		unmount = unmount,
	}
end

return createRoactRenderer
