local run = require("./run")

local function installPackages(rojoProjectPath: string, sourcemapPath: string, packagesPath: string)
	run("wally", { "install" })
	run("rojo", { "sourcemap", rojoProjectPath, "-o", sourcemapPath })
	run("wally-package-types", { "--sourcemap", sourcemapPath, packagesPath })
end

return installPackages
