local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local Sift = require(flipbook.Packages.Sift)

local function useDescendants(parent: Instance, predicate: (descendant: Instance) -> boolean): { Instance }
	local descendants: { Instance }, setDescendants = React.useState({})

	local onDescendantChanged = React.useCallback(function(descendant: Instance)
		local exists = table.find(descendants, descendant)
		if predicate(descendant) then
			if exists then
				-- Force a re-render. Nothing about the state changed, but the
				-- module uses a new name now
				setDescendants(table.clone(descendants))
			else
				setDescendants(Sift.Array.push(descendants, descendant))
			end
		else
			if exists then
				setDescendants(Sift.Array.filter(descendants, function(other: Instance)
					return descendant ~= other
				end))
			end
		end
	end, { predicate, descendants, setDescendants })

	-- Setup the initial list of descendants for the current parent
	React.useEffect(function()
		setDescendants(Sift.Array.filter(parent:GetDescendants(), predicate))
	end, { parent })

	React.useEffect(function()
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
