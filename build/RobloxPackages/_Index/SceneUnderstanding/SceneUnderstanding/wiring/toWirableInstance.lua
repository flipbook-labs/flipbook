local Root = script:FindFirstAncestor("SceneUnderstanding")

local isWirable = require(Root.wiring.isWirable)
local types = require(Root.wiring.types)

type WirableInstance = types.WirableInstance

local function toWirableInstance(instance: Instance?): WirableInstance?
	if instance and isWirable(instance) then
		return (instance :: any) :: WirableInstance
	end
	return nil
end

return toWirableInstance
