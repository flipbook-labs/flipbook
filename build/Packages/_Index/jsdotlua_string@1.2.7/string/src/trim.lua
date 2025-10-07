local trimStart = require(script.Parent:WaitForChild('trimStart'))
local trimEnd = require(script.Parent:WaitForChild('trimEnd'))

return function(source: string): string
	return trimStart(trimEnd(source))
end
