local function usePrevious(hooks: any, value: any)
	local prev = hooks.useValue(nil)

	hooks.useEffect(function()
		prev.value = value
	end, { value })

	return prev.value
end

return usePrevious
