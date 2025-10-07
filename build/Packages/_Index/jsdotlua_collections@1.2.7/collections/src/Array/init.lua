local ES7Types = require(script.Parent.Parent:WaitForChild('es7-types'))

export type Array<T> = ES7Types.Array<T>

return {
	concat = require(script:WaitForChild('concat')),
	every = require(script:WaitForChild('every')),
	filter = require(script:WaitForChild('filter')),
	find = require(script:WaitForChild('find')),
	findIndex = require(script:WaitForChild('findIndex')),
	flat = require(script:WaitForChild('flat')),
	flatMap = require(script:WaitForChild('flatMap')),
	forEach = require(script:WaitForChild('forEach')),
	from = require(script:WaitForChild('from')),
	includes = require(script:WaitForChild('includes')),
	indexOf = require(script:WaitForChild('indexOf')),
	isArray = require(script:WaitForChild('isArray')),
	join = require(script:WaitForChild('join')),
	map = require(script:WaitForChild('map')),
	reduce = require(script:WaitForChild('reduce')),
	reverse = require(script:WaitForChild('reverse')),
	shift = require(script:WaitForChild('shift')),
	slice = require(script:WaitForChild('slice')),
	some = require(script:WaitForChild('some')),
	sort = require(script:WaitForChild('sort')),
	splice = require(script:WaitForChild('splice')),
	unshift = require(script:WaitForChild('unshift')),
}
