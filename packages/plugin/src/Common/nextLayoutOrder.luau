local layoutOrder = 0

local function nextLayoutOrder()
	layoutOrder += 1
	return layoutOrder
end

return nextLayoutOrder
