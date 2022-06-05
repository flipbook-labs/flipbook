local function usePrevious(hooks: any, value: any)
	local previous = hooks.useValue(nil)

	hooks.useEffect(function()
		previous.value = value
	end, { value })

	return previous.value
end

return usePrevious
