local clean = require("./lib/clean")
local compile = require("./lib/compile")
local constants = require("./lib/constants")
local getPluginsPath = require("./lib/getPluginsPath")
local process = require("@lune/process")
local run = require("./lib/run")

local target = "dev"

local pluginPath = `{getPluginsPath(process.os)}/{constants.PLUGIN_FILENAME}`

clean()
compile(target)

if target == "prod" then
	run("rm", { "-rf", `{constants.BUILD_PATH}/**/*.spec.luau` })
	run("rm", { "-rf", `{constants.BUILD_PATH}/**/*.story.luau` })
	run("rm", { "-rf", `{constants.BUILD_PATH}/**/*.storybook.luau` })
end

run("rojo", { "build", "-o", pluginPath })
