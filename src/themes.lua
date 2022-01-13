local function fromHex(decimal: number): Color3
	local red = bit32.band(bit32.rshift(decimal, 16), 2 ^ 8 - 1)
	local green = bit32.band(bit32.rshift(decimal, 8), 2 ^ 8 - 1)
	local blue = bit32.band(decimal, 2 ^ 8 - 1)

	return Color3.fromRGB(red, green, blue)
end

return {
	Light = {
		background = fromHex(0xF3F4F6),
	},

	Dark = {
		background = fromHex(0x171717),
	},
}
