local fs = require("@lune/fs")

local constants = require("./lib/constants")
local run = require("./lib/run")

local function toPascalCase(text: string)
	return text:gsub("(.+)(%.%w+)$", function(name, ext)
		return name:gsub("(%a)(%w+)", function(first, rest)
			return `{first:upper()}{if rest then rest else ""}`
		end):gsub("%-", "") .. ext
	end)
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
