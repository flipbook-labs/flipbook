local process = require("@lute/process")

type Options = {
	cwd: string?,
	env: { [string]: string }?,
	stdio: any,
}

local function run(program: string, params: { string }, options: Options?): string
	local command = `{program} {table.concat(params, " ")}`
	-- stdio.write(stdio.style("bold"))
	print(`> {command}`)
	-- stdio.write(stdio.style("reset"))

	local result = process.run({
		program,
		table.unpack(params),
	}, {
		shell = true,
		stdio = if options and options.stdio then options.stdio else "inherit",
		cwd = if options then options.cwd else nil,
		env = if options then options.env else nil,
	})

	if result.ok then
		return result.stdout:gsub("^\n", ""):gsub("\n$", "")
	else
		error(result.stderr, 2)
	end
end

return run
