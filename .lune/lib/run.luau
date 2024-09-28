local process = require("@lune/process")
local stdio = require("@lune/stdio")

type Options = {
	cwd: string?,
	env: { [string]: string }?,
}

local function run(program: string, params: { string }, options: Options?)
	stdio.write(stdio.style("bold"))
	print(`> {program} {table.concat(params, " ")}`)
	stdio.write(stdio.style("reset"))

	local result = process.spawn(program, params, {
		stdio = "inherit",
		shell = true,
		cwd = if options then options.cwd else nil,
		env = if options then options.env else nil,
	})

	local output = if result.ok then result.stdout else result.stderr

	output = output:gsub("\n$", "")

	if not result.ok or result.code > 0 then
		error(output)
	end

	return output
end

return run
