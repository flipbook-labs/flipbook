local function isWirable(instance: Instance): boolean
	local success = pcall(function()
		local anyInstance = instance :: any
		anyInstance:GetInputPins()
		anyInstance:GetOutputPins()
		anyInstance:GetConnectedWires("Foo")
	end)

	return success
end

return isWirable
