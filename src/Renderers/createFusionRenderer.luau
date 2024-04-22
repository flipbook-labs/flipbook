local flipbook = script:FindFirstAncestor("flipbook")

local createRobloxRenderer = require(flipbook.Renderers.createRobloxRenderer)
local types = require(flipbook.Renderers.types)

type Renderer = types.Renderer

type Packages = {
	Fusion: any,
}

local function createFusionRenderer(packages: Packages): Renderer
	local Fusion = packages.Fusion
	local robloxRenderer = createRobloxRenderer()

	local function transformArgs(args)
		local newArgs = {}
		for k, v in args do
			newArgs[k] = Fusion.Value(v)
		end
		return newArgs
	end

	local function shouldUpdate(context, prevContext)
		if context.args ~= prevContext.args then
			return false
		else
			return nil
		end
	end

	return {
		transformArgs = transformArgs,
		shouldUpdate = shouldUpdate,
		mount = robloxRenderer.mount,
		unmount = robloxRenderer.unmount,
	}
end

return createFusionRenderer
