local types = require(script.Parent.Parent.types)

local function convertLegacyStory(module: ModuleScript, story: types.HoarcekatStory)
	return {
		name = module.Name,
		story = story,
		isLegacy = true,
	}
end

return convertLegacyStory
