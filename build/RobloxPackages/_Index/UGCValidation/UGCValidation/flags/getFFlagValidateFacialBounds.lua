local root = script.Parent.Parent

local getEngineFeatureEngineUGCNewFACSChecks = require(root.flags.getEngineFeatureEngineUGCNewFACSChecks)

game:DefineFastFlag("ValidateFacialBounds", false)

return function()
	return getEngineFeatureEngineUGCNewFACSChecks() and game:GetFastFlag("ValidateFacialBounds")
end
