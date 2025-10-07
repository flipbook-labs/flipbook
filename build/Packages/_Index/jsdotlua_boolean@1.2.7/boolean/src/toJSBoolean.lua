local Number = require(script.Parent.Parent:WaitForChild('number'))
-- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Boolean

return function(val: any): boolean
	return not not val and val ~= 0 and val ~= "" and not Number.isNaN(val)
end
