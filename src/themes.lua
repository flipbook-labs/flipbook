local function fromHex(decimal: number): Color3
	local red = bit32.band(bit32.rshift(decimal, 16), 2 ^ 8 - 1)
	local green = bit32.band(bit32.rshift(decimal, 8), 2 ^ 8 - 1)
	local blue = bit32.band(decimal, 2 ^ 8 - 1)

	return Color3.fromRGB(red, green, blue)
end

return {
	Brand = fromHex(0x933EA),

	Light = {
		background = fromHex(0xF3F4F6),
		stroke = fromHex(0xD1D5DB),
		icons = {
			search = fromHex(0x111228),
		},
	},

	Dark = {
		background = fromHex(0x171717),
	},
}
