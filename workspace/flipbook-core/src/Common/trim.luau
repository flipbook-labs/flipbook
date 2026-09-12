local function trim(value: string): string
	local trimmed = value:match("^%s*(.-)%s*$")
	return if trimmed then trimmed else value
end

return trim
