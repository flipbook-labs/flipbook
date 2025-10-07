local function isLayeredClothing(instance: any): boolean
	return instance:FindFirstChildWhichIsA("WrapLayer", true)
end

return isLayeredClothing
