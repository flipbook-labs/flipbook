local function setGlobal(key: string, value: any): any
	-- selene: allow(global_usage)
	local prevValue = _G[key]
	-- selene: allow(global_usage)
	_G[key] = value
	return prevValue
end

local function withGlobals(globals: { [string]: any })
	local prevValues = {}

	for key, value in globals do
		prevValues[key] = setGlobal(key, value)
	end

	return function()
		for key in globals do
			setGlobal(key, prevValues[key])
		end
	end
end

return withGlobals
