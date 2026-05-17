local getTaggedRuntimes = require("@root/Embedding/runtime/getTaggedRuntimes")

local function enforceSingleRuntime(preferredRuntime: Instance?): Instance?
	local runtimes = getTaggedRuntimes()
	local runtimeToKeep = preferredRuntime or runtimes[1]

	for _, taggedRuntime in runtimes do
		if taggedRuntime ~= runtimeToKeep then
			taggedRuntime:Destroy()
		end
	end

	return runtimeToKeep
end

return enforceSingleRuntime
