local function getConnectedWires(instance: Instance, pin: "Input" | "Output"): { Wire }
	local success, result = pcall(function()
		return (instance :: any):GetConnectedWires(pin)
	end)

	return if success then result else {}
end

return getConnectedWires
