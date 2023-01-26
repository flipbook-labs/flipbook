local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)

local function usePrevious(value: any)
	local previous = React.useRef(nil)

	React.useEffect(function()
		previous.current = value
	end, { value })

	return previous.current
end

return usePrevious
