local constants = require("./constants")
local fs = require("@lune/fs")
local run = require("./run")

type Target = "prod" | "dev"

local function compile(target: Target)
	fs.writeDir(constants.BUILD_PATH)

	run("rojo", {
		"sourcemap",
		constants.ROJO_BUILD_PROJECT,
		"-o",
		constants.DARKLUA_SOURCEMAP_PATH,
	})

	run("darklua", {
		"process",
		constants.SOURCE_PATH,
		constants.BUILD_PATH,
	})

	if target == "dev" then
		run("darklua", {
			"process",
			"example",
			`{constants.BUILD_PATH}/Example`,
		})
	end
end

return compile
