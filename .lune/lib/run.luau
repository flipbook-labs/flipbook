local process = require("@lune/process")

type Options = {
	cwd: string?,
	env: { [string]: string }?,
}

local function run(program: string, params: { string }, options: Options?)
	print(`> {program} {table.concat(params, " ")}`)

	local result = process.spawn(program, params, {
		stdio = "inherit",
		shell = true,
		cwd = if options then options.cwd else nil,
		env = if options then options.env else nil,
	})

	if result.code > 0 then
		process.exit(result.code)
	end

	local output = if result.ok then result.stdout else result.stderr

	output = output:gsub("\n$", "")

	return output
end

return run
