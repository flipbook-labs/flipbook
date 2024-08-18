local Sift = require("@pkg/Sift")

local types = require("@root/Renderers/types")

type Args = types.Args
type Context = types.Context
type Renderer = types.Renderer

local function render<T>(renderer: Renderer, container: Instance, element: T, initialArgs: Args?)
	local prevContext: Context?

	local function renderOnce(args: Args?)
		local context: Context = {
			container = container,
			args = args,
		}

		if renderer.transformContext then
			context = renderer.transformContext(context, prevContext)
		end

		if not renderer.shouldUpdate or renderer.shouldUpdate(context, prevContext) then
			renderer.mount(container, element, context)
		end

		prevContext = context
	end

	local function update(newArgs: Args?)
		if renderer.update then
			local context = Sift.Dictionary.join(prevContext, {
				args = newArgs,
			})
			renderer.update(context)
		else
			renderOnce(newArgs)
		end
	end

	local function unmount()
		if renderer.unmount then
			renderer.unmount(prevContext)
		end
		container:ClearAllChildren()
	end

	renderOnce(initialArgs)

	return {
		update = update,
		unmount = unmount,
	}
end

return render
