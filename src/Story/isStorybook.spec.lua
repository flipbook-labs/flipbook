return function()
	local isStorybook = require(script.Parent.isStorybook)

	it("should return 'true' for a table with a 'storyRoots' field", function()
		local pass1 = {
			storyRoots = {},
		}
		local pass2 = {
			storyRoots = {
				Instance.new("Folder"),
			},
		}

		expect(isStorybook(pass1)).to.equal(true)
		expect(isStorybook(pass2)).to.equal(true)
	end)

	it("should return 'false' if the 'storyRoots' field is not found", function()
		local fail = {
			foo = "bar",
		}

		expect(isStorybook(fail)).to.equal(false)
	end)

	it("should return 'false' for primitives", function()
		local primitives = {
			true,
			"string",
			1234,
		}

		for _, primitive in ipairs(primitives) do
			expect(isStorybook(primitive)).to.equal(false)
		end
	end)
end
