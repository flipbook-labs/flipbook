local function mapColors(spring, color1, color2)
	return spring:map(function(alpha)
		return color1:Lerp(color2, alpha)
	end)
end

return mapColors
