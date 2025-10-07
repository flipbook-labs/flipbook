--[=[
	Jest and TestEZ matchers to help facilitate UI and design business logic in
	our 2D and 3D apps in a human readable way.

	Depending on which test runner you're using, you will need to include a `beforeAll` block in your spec file to add the matchers:


	```lua
	-- Jest
	return function()
		local JestGlobals = require(path.to.Packages.Dev.JestGlobals)
		local expect = JestGlobals.expect
		local CollisionMatchers2D = require(path.to.Packages.Dev.CollisionMatchers2D)

		beforeAll(function()
			expect.extend(CollisionMatchers2D.Jest)
		end)

		-- ...
	end
	```

	```lua
	-- TestEZ
	return function()
		local CollisionMatchers2D = require(path.to.Packages.Dev.CollisionMatchers2D)

		beforeAll(function()
			expect.extend(CollisionMatchers2D.TestEZ)
		end)

		-- ...
	end
	```

	@class CollisionMatchers2D
]=]
return {
	TestEZ = require(script.TestEZ),
	Jest = require(script.Jest),
}
