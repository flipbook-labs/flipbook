return function()
	local Roact = require(script.Parent.Packages.Roact)
	local isLegacyStory = require(script.Parent.isLegacyStory)

	local legacy = function(_target: Instance)
		return function()
			return nil
		end
	end

	local story = {
		story = Roact.createElement("Frame"),
	}

	it("should return true for legacy stories", function()
		expect(isLegacyStory(legacy)).to.equal(true)
	end)

	it("should return false for this plugin's story format", function()
		expect(isLegacyStory(story)).to.equal(false)
	end)
end
