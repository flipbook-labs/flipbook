local function trim(value: string): string
	local withoutLeadingWhitespace = value:gsub("^%s+", "")
	local trimmed = withoutLeadingWhitespace:gsub("%s+$", "")
	return trimmed
end

return trim
