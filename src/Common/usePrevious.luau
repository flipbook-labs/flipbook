local React = require("@pkg/React")

local function usePrevious(value: any)
	local previous = React.useRef(nil)

	React.useEffect(function()
		previous.current = value
	end, { value })

	return previous.current
end

return usePrevious
