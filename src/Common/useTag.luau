local CollectionService = game:GetService("CollectionService")

local React = require("@pkg/React")

local useCallback = React.useCallback
local useEffect = React.useEffect
local useState = React.useState

local function useTag(tagName: string): { Instance }
	local instances, setInstances = useState({})

	local sync = useCallback(function()
		setInstances(CollectionService:GetTagged(tagName))
	end, { tagName })

	useEffect(function()
		local added = CollectionService:GetInstanceAddedSignal(tagName):Connect(sync)
		local removed = CollectionService:GetInstanceRemovedSignal(tagName):Connect(sync)

		sync()

		return function()
			added:Disconnect()
			removed:Disconnect()
		end
	end, { tagName, sync })

	return instances
end

return useTag
