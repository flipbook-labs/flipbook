--!strict
-- ROBLOX deviation: Initializes the reconciler with this package's host
-- config and returns the resulting module

local initializeReconciler = require(script.Parent.Parent:WaitForChild('react-reconciler'))

local ReactRobloxHostConfig = require(script.Parent:WaitForChild('client'):WaitForChild('ReactRobloxHostConfig'))

return initializeReconciler(ReactRobloxHostConfig)
