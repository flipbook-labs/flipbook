local flipbook = script:FindFirstAncestor("flipbook")

local TestEZ = require(flipbook.Packages.TestEZ)

local function runTests()
	-- Prune any tests that we don't own
	for _, descendant in ipairs(flipbook.Packages:GetDescendants()) do
		if descendant.Name:match("%.spec$") then
			descendant:Destroy()
		end
	end

	local results = TestEZ.TestBootstrap:run({
		flipbook,
	})

	return results.failureCount == 0
end

return runTests
