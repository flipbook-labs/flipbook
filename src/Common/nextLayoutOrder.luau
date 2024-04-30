local order = 0

local function nextLayoutOrder()
	order += 1
	return order
end

return nextLayoutOrder
