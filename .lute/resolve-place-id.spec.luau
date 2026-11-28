local process = require("@std/process")
local test = require("@std/test")

local function runScript(args: { string })
	local command = { "lute", "run", "resolve-place-id" }
	table.move(args, 1, #args, #command + 1, command)
	return process.run(command)
end

test.case("documents the place ID lookup", function(asserts)
	local result = runScript({ "--help" })

	asserts.eq(true, result.ok)
	asserts.strContains(result.stdout, "Usage: lute run resolve-place-id <universe-id> <place-name>")
end)

test.case("fails without a place name", function(asserts)
	local result = runScript({ "123" })

	asserts.eq(false, result.ok)
	asserts.strContains(result.stdout, "Usage: lute run resolve-place-id")
end)
