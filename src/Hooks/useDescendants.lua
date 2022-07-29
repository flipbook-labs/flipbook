local flipbook = script:FindFirstAncestor("flipbook")

local Llama = require(flipbook.Packages.Llama)

local function useDescendants(hooks: any, parent: Instance, predicate: (descendant: Instance) -> boolean): { Instance }
	local descendants: { Instance }, setDescendants = hooks.useState({})

	local onDescendantChanged = hooks.useCallback(function(descendant: Instance)
		local exists = table.find(descendants, descendant)
		if predicate(descendant) then
			if exists then
				-- Force a re-render. Nothing about the state changed, but the
				-- module uses a new name now
				setDescendants(table.clone(descendants))
			else
				setDescendants(Llama.List.append(descendants, descendant))
			end
		else
			if exists then
				setDescendants(Llama.List.filter(descendants, function(other: Instance)
					return descendant ~= other
				end))
			end
		end
	end, { predicate, descendants, setDescendants })

	-- Setup the initial list of descendants for the current parent
	hooks.useEffect(function()
		setDescendants(Llama.List.filter(parent:GetDescendants(), predicate))
	end, { parent })

	hooks.useEffect(function()
		local connections = {
			parent.DescendantAdded:Connect(onDescendantChanged),
			parent.DescendantRemoving:Connect(onDescendantChanged),
		}

		-- Listen for name changes and update the list of descendants
		for _, descendant in parent:GetDescendants() do
			table.insert(
				connections,
				descendant:GetPropertyChangedSignal("Name"):Connect(function()
					onDescendantChanged(descendant)
				end)
			)
		end

		return function()
			for _, conn in connections do
				conn:Disconnect()
			end
		end
	end, { parent, onDescendantChanged })

	return descendants
end

return useDescendants
