local process = require("@lune/process")
local stdio = require("@lune/stdio")

type Options = {
	cwd: string?,
	env: { [string]: any }?,
}

local function run(program: string, params: { string }, options: Options?): string
	stdio.write(stdio.style("bold"))
	print(`> {program} {table.concat(params, " ")}`)
	stdio.write(stdio.style("reset"))

	local result = process.exec(program, params, {
		stdio = "inherit",
		cwd = if options then options.cwd else nil,
		env = if options then options.env else nil,
	})

	if result.code == 0 then
		return result.stdout:gsub("\n$", "")
	else
		error(result.stderr)
	end
end

return run
