local flipbook = script:FindFirstAncestor("flipbook")

local t = require(flipbook.Packages.t)

local isStory = t.strictInterface({
	story = t.union(t.table, t.callback),

	name = t.optional(t.string),
	summary = t.optional(t.string),
	controls = t.optional(t.table),
	roact = t.optional(t.table),
})

return isStory
