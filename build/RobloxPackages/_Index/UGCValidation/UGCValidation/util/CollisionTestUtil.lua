--[[
	CollisionTestUtil.lua exposes utility functions to test if shapes are intersecting
]]

local CollisionTestUtil = {}

function CollisionTestUtil.pointInAxisAlignedBounds(
	testPointWorld: Vector3,
	boundsPositionWorld: Vector3,
	boundsSize: Vector3
): boolean
	local testPointLocal = testPointWorld - boundsPositionWorld
	return testPointLocal.X >= -boundsSize.X / 2
		and testPointLocal.X <= boundsSize.X / 2
		and testPointLocal.Y >= -boundsSize.Y / 2
		and testPointLocal.Y <= boundsSize.Y / 2
		and testPointLocal.Z >= -boundsSize.Z / 2
		and testPointLocal.Z <= boundsSize.Z / 2
end

return CollisionTestUtil
