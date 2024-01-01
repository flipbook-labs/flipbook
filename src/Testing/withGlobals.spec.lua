return function()
	local withGlobals = require(script.Parent.withGlobals)

	it("should set a global value until the cleanup function is called", function()
		expect(_G.FOO).never.to.be.ok()

		local cleanup = withGlobals({
			FOO = true,
		})

		expect(_G.FOO).to.be.ok()

		cleanup()

		expect(_G.FOO).never.to.be.ok()
	end)

	it("should work for any datatype", function()
		local globals = {
			GlobalBool = true,
			GlobalString = "string",
			GlobalInt = 10,
		}

		local cleanup = withGlobals(globals)

		for key, value in globals do
			expect(_G[key]).to.equal(value)
		end

		cleanup()

		for key, value in globals do
			expect(_G[key]).never.to.equal(value)
		end
	end)
end
