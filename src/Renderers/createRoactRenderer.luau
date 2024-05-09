local types = require("@root/Renderers/types")

type Renderer = types.Renderer

type Packages = {
	Roact: any,
}

local function createRoactRenderer(packages: Packages): Renderer
	local Roact = packages.Roact
	local container
	local handle

	local function mount(element)
		container = Instance.new("Folder")
		handle = Roact.mount(element, container, "RoactRenderer")
		return container
	end

	local function unmount()
		Roact.unmount(handle)
		container:Destroy()
	end

	return {
		mount = mount,
		unmount = unmount,
	}
end

return createRoactRenderer
