local process = require("@lune/process")

local function run(program: string, params: { string })
	print(`> {program} {table.concat(params, " ")}`)

	local result = process.spawn(program, params, {
		stdio = "inherit",
		shell = true,
	})

	if result.code > 0 then
		process.exit(result.code)
	end

	if result.ok then
		return result.stdout
	else
		return result.stderr
	end
end

return run
