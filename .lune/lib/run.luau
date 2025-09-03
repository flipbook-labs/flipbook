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

	local result = process.exec(program, params, {
		stdio = "forward",
		shell = true,
		cwd = if options then options.cwd else nil,
		env = if options then options.env else nil,
	})

	local out
	if result.ok then
		out = result.stdout
	else
		out = result.stderr
	end

	out = out:gsub("\n$", "")

	return out, result.ok
end

return run
