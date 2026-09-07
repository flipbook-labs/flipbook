local function trim(value: string): string
	return value:match("^%s*(.-)%s*$") or value
end

return trim
