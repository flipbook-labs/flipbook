local types = require(script.Parent.types)

local function convertLegacyStory(module: ModuleScript, story: types.LegacyStory)
	return {
		name = module.Name,
		story = story,
		isLegacy = true,
	}
end

return convertLegacyStory
