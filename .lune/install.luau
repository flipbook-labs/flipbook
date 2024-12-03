local fs = require("@lune/fs")

local constants = require("./lib/constants")
local run = require("./lib/run")

local function toPascalCase(filename: string)
	local name, ext = filename:match("(.+)(%.%w+)$")

	local function upperFirstLetter(first: string, rest: string)
		return `{first:upper()}{if rest then rest else ""}`
	end

	if name and ext then
		name = name:gsub("(%a)(%w+)", upperFirstLetter :: any):gsub("%-", "")

		return name .. ext
	else
		return filename
	end
end

local function convertPackageNames()
	for _, module in fs.readDir(constants.PACKAGES_PATH) do
		local modulePath = `{constants.PACKAGES_PATH}/{module}`

		if not fs.isFile(modulePath) then
			continue
		end

		local pascalModule = toPascalCase(module)

		if module == pascalModule then
			print(`name would be unchanged for {module}. skipping...`)
			continue
		end

		run("mv", { modulePath, `{constants.PACKAGES_PATH}/{pascalModule}` })
	end
end

run("pesde", { "install" })

print("renaming linker modules for backwards compatibility...")
convertPackageNames()
