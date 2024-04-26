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

	local function mount(container, element, context)
		root = ReactRoblox.createRoot(container)

		if typeof(element) == "function" then
			element = React.createElement(element, context.args)
		end

		root:render(element)
	end

	local function unmount()
		root:unmount()
	end

	return {
		mount = mount,
		unmount = unmount,
	}
end

return createReactRenderer
