local types = require("@root/Renderers/types")

type Renderer = types.Renderer

type Packages = {
	React: any,
	ReactRoblox: any,
}

local function createReactRenderer(packages: Packages): Renderer
	local React = packages.React
	local ReactRoblox = packages.ReactRoblox

	local container = Instance.new("Folder")
	local root = ReactRoblox.createRoot(container)

	local function mount(element)
		if typeof(element) == "function" then
			element = React.createElement(element, props)
		end

		root:render(element)

		return container
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
