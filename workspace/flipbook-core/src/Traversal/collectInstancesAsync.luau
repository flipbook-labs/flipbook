local Signals = require("@rbxpkg/Signals")

local function collectInstancesAsync(
	root: Instance,
	predicate: (instance: Instance) -> boolean
): Signals.getter<{ Instance }>
	-- ...
end

return collectInstancesAsync
