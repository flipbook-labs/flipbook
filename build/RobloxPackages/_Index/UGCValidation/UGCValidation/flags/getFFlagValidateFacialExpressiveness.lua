local root = script.Parent.Parent

local getEngineFeatureEngineUGCNewFACSChecks = require(root.flags.getEngineFeatureEngineUGCNewFACSChecks)

game:DefineFastFlag("ValidateFacialExpressiveness", false)

return function()
	return getEngineFeatureEngineUGCNewFACSChecks() and game:GetFastFlag("ValidateFacialExpressiveness")
end
