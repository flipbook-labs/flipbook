local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local useState = React.useState
local useEffect = React.useEffect

local function useHoveredGuiObjects(root: Instance?): { GuiObject }
	local hoveredObjects, setHoveredObjects = useState({} :: { GuiObject })

	useEffect(function()
		if not root then
			return
		end

		local connections = {}

		local function onAdded(instance: Instance)
			if not instance:IsA("GuiObject") then
				return
			end

			table.insert(
				connections,
				instance.MouseEnter:Connect(function()
					setHoveredObjects(function(prev)
						return Sift.List.prepend(prev, instance)
					end)
				end)
			)

			table.insert(
				connections,
				instance.MouseLeave:Connect(function()
					setHoveredObjects(function(prev)
						return Sift.List.filter(prev, function(guiObject: GuiObject)
							return guiObject ~= instance
						end)
					end)
				end)
			)

			table.insert(
				connections,
				instance.AncestryChanged:Connect(function(_, newParent)
					if newParent and newParent:IsDescendantOf(root) then
						setHoveredObjects(Sift.List.filter(hoveredObjects, function(guiObject: GuiObject)
							return guiObject ~= instance
						end))
					end
				end)
			)
		end

		for _, descendant in root:GetDescendants() do
			onAdded(descendant)
		end

		table.insert(connections, root.DescendantAdded:Connect(onAdded))

		return function()
			for _, connection in connections do
				connection:Disconnect()
			end
		end
	end, { root })

	return hoveredObjects
end

return useHoveredGuiObjects
