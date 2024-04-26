local process = require("@lune/process")

local function run(program, params)
	print(`> {program} {table.concat(params, " ")}`)

	local result = process.spawn(program, params, {
		stdio = "inherit",
	})

	if result.code > 0 then
		process.exit(result.code)
	end

	return result
end

return run
