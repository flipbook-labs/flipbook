return {
	assign = require(script:WaitForChild('assign')),
	entries = require(script:WaitForChild('entries')),
	freeze = require(script:WaitForChild('freeze')),
	is = require(script:WaitForChild('is')),
	isFrozen = require(script:WaitForChild('isFrozen')),
	keys = require(script:WaitForChild('keys')),
	preventExtensions = require(script:WaitForChild('preventExtensions')),
	seal = require(script:WaitForChild('seal')),
	values = require(script:WaitForChild('values')),
	-- Special marker type used in conjunction with `assign` to remove values
	-- from tables, since nil cannot be stored in a table
	None = require(script:WaitForChild('None')),
}
