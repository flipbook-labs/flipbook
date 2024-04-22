local types = require("@root/Renderers/types")

type Args = types.Args
type Context = types.Context
type Renderer = types.Renderer

type UpdateFn = () -> ()

local function render(renderer: Renderer, target: Instance, element: any, args: Args): UpdateFn
	local handle: Instance
	local context: Context = {
		target = target,
		element = element,
		args = args,
	}
	local prevContext: Context? = nil

	local function renderOnce()
		if not renderer.shouldUpdate or renderer.shouldUpdate(context, prevContext) then
			if renderer.unmount then
				renderer.unmount(context)
			else
				handle:Destroy()
			end

			handle = renderer.mount(target, element, context)
		end
	end

	renderOnce()

	return function()
		renderOnce()
	end
end

return render
