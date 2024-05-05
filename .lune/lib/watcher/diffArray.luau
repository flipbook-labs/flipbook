local function diffArray<T>(base: { T }, compare: { T }): { T }
	local diff = {}
	for _, value in compare do
		if not table.find(base, value) then
			table.insert(diff, value)
		end
	end
	for _, value in base do
		if not table.find(compare, value) then
			table.insert(diff, value)
		end
	end
	return diff
end

return diffArray
