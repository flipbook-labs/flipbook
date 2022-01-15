return function()
	local Roact = require(script.Parent.Parent.Packages.Roact)
	local isHoarcekatStory = require(script.Parent.isHoarcekatStory)

	local hoarcekat = function(_target: Instance)
		return function()
			return nil
		end
	end

	local story = {
		story = Roact.createElement("Frame"),
	}

	it("should return true for hoarcekat stories", function()
		expect(isHoarcekatStory(hoarcekat)).to.equal(true)
	end)

	it("should return false for this plugin's story format", function()
		expect(isHoarcekatStory(story)).to.equal(false)
	end)
end
