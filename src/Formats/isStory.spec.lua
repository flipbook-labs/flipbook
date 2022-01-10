return function()
	local isStory = require(script.Parent.isStory)

	it("should return `true` for a table with a `story` field", function()
		local pass = { story = {} }
		expect(isStory(pass)).to.equal(true)
	end)

	it("should return false if the story field is not found", function()
		local fail = { foo = "bar" }
		expect(isStory(fail)).to.equal(false)
	end)

	it("should return `false` for primitives", function()
		local primitives = {
			true,
			"string",
			1234,
		}

		for _, primitive in ipairs(primitives) do
			expect(isStory(primitive)).to.equal(false)
		end
	end)
end
