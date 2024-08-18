local Sift = require("@pkg/Sift")

local createRobloxRenderer = require("@root/Renderers/createRobloxRenderer")
local types = require("@root/Renderers/types")

type Renderer = types.Renderer

type Packages = {
	Fusion: any,
}

local function createFusionRenderer(packages: Packages): Renderer
	local Fusion = packages.Fusion
	local robloxRenderer = createRobloxRenderer()

	local function transformContext(context, prevContext)
		if context.args and prevContext and prevContext.args then
			local transformed = table.clone(context)

			transformed.args = Sift.Dictionary.map(transformed.args, function(arg, key)
				-- Retain Fusion.Value identities and update the internal value with
				-- the new arg's value
				local prevArg = if prevContext.args then prevContext.args[key] else nil
				if prevArg then
					prevArg:set(arg)
					return prevArg
				end
				return Fusion.Value(arg)
			end)

			return transformed
		end
		return context
	end

	local function shouldUpdate(context, prevContext)
		-- Arg changes should never trigger a remount. We retain the Value
		-- identities to Fusion can handle its update logic
		if prevContext and not Sift.Dictionary.equals(context.args, prevContext.args) then
			return false
		end
		return true
	end

	return {
		mount = robloxRenderer.mount,
		unmount = robloxRenderer.unmount,
		shouldUpdate = shouldUpdate,
		transformContext = transformContext,
	}
end

return createFusionRenderer
