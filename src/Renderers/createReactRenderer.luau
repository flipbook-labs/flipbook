local types = require("@root/Renderers/types")

type Renderer = types.Renderer

type Packages = {
	React: any,
	ReactRoblox: any,
}

local function createReactRenderer(packages: Packages): Renderer
	local React = packages.React
	local ReactRoblox = packages.ReactRoblox

	local root
	local currentElement

	local function reactRender(element, context)
		local props = if context then context.args else nil

		currentElement = element

		element = React.createElement(element, props)
		root:render(element)
	end

	local function mount(container, element, context)
		root = ReactRoblox.createRoot(container)
		reactRender(element, context)
	end

	local function update(newContext)
		if currentElement then
			reactRender(currentElement, newContext)
		end
	end

	local function unmount()
		root:unmount()
	end

	return {
		mount = mount,
		update = update,
		unmount = unmount,
	}
end

return createReactRenderer
