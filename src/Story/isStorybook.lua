local flipbook = script:FindFirstAncestor("flipbook")

local t = require(flipbook.Packages.t)

local isStorybook = t.strictInterface({
	storyRoots = t.array(t.Instance),

	name = t.optional(t.string),
	roact = t.optional(t.table),
})

return isStorybook
