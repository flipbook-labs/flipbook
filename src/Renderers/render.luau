local types = require("@root/Renderers/types")

type Args = types.Args
type Context = types.Context
type Renderer = types.Renderer

type UpdateFn = () -> ()

local function render<T>(renderer: Renderer, container: Instance, element: T, args: Args?): UpdateFn
	local handle: Instance
	local context: Context = {
		container = container,
		args = args,
	}
	local prevContext: Context? = nil

	if not renderer.shouldUpdate or renderer.shouldUpdate(context, prevContext) then
		if renderer.unmount then
			renderer.unmount(context)
		else
			handle:Destroy()
		end

		handle = renderer.mount(container, element, context)
		prevContext = context
	end

	local function rerender(newArgs: Args?)
		render(renderer, container, element, newArgs)
	end

	return rerender
end

return render
