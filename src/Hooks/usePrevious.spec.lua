local flipbook = script:FindFirstAncestor("flipbook")

return function()
	local testHook = require(flipbook.TestHelpers.testHook)
	local usePrevious = require(script.Parent.usePrevious)

	it("should use the last value", function()
		local state = nil
		local prevState = nil

		testHook(function()
			prevState = usePrevious(state)
		end)

		expect(prevState).to.equal(nil)

		state = true
		testHook(function()
			prevState = usePrevious(state)
		end)

		expect(prevState).to.equal(true)

		state = false
		testHook(function()
			prevState = usePrevious(state)
		end)

		expect(prevState).to.equal(false)
	end)
end
