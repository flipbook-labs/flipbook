local ContentProvider = game:GetService("ContentProvider")

local Llama = require(script.Parent.Parent.Packages.Llama)

local function preloadAssets(assets: { [string]: string })
	local assetIds = Llama.Dictionary.values(assets)

	task.spawn(function()
		ContentProvider:PreloadAsync(assetIds)
	end)
end

return preloadAssets
