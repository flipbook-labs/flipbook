local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)

local function usePrevious(value: any)
	local previous = React.useValue(nil)

	React.useEffect(function()
		previous.value = value
	end, { value })

	return previous.value
end

return usePrevious
