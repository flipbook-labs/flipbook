return function()
	local flipbook = script:FindFirstAncestor("flipbook")

	local t = require(flipbook.Packages.t)
	local getLineFromTypecheckError = require(script.Parent.getLineFromTypecheckError)

	it("should return the line that the offending variable is on", function()
		local module = Instance.new("ModuleScript")
		module.Source = [[
			return {
				foo = true
			}
		]]

		local check = t.strictInterface({
			foo = t.number,
		})

		local success, message = check(require(module))

		local line = getLineFromTypecheckError(message, module.Source)

		expect(success).to.equal(false)
		expect(line).to.equal(2)
	end)

	it("should return nothing when no matching line is found", function()
		local module = Instance.new("ModuleScript")
		module.Source = [[
			return {
				foo = true
			}
		]]

		local check = t.strictInterface({
			bar = t.bool,
		})

		local success, message = check(require(module))

		local line = getLineFromTypecheckError(message, module.Source)

		expect(success).to.equal(false)
		expect(line).to.never.be.ok()
	end)
end
