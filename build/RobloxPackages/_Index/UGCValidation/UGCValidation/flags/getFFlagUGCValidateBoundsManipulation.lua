--!strict
local root = script.Parent.Parent

local getEngineFeatureEngineUGCValidateBoundsManipulation =
	require(root.flags.getEngineFeatureEngineUGCValidateBoundsManipulation)

game:DefineFastFlag("UGCValidateBoundsManipulation", false)

return function()
	return game:GetFastFlag("UGCValidateBoundsManipulation") and getEngineFeatureEngineUGCValidateBoundsManipulation()
end
