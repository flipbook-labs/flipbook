local clean = require("./lib/clean")
local compile = require("./lib/compile")
local constants = require("./lib/constants")
local getPluginsPath = require("./lib/getPluginsPath")
local parseArgs = require("./lib/parseArgs")
local process = require("@lune/process")
local run = require("./lib/run")

type Args = {
	target: ("prod" | "dev")?,
	output: string?,
	watch: boolean?,
}

local args: Args = parseArgs(process.args)

local target = if args.target then args.target else "prod"
local output = if args.output then args.output else `{getPluginsPath(process.os)}/{constants.PLUGIN_FILENAME}`

clean()
compile(target)

if target == "prod" then
	run("rm", { "-rf", `{constants.BUILD_PATH}/**/*.spec.luau` })
	run("rm", { "-rf", `{constants.BUILD_PATH}/**/*.story.luau` })
	run("rm", { "-rf", `{constants.BUILD_PATH}/**/*.storybook.luau` })
end

run("rojo", { "build", "-o", output })

-- TODO: Watch for file changes and rebuild
-- if args.watch then
-- 	run("npx", {
-- 		"-y",
-- 		"chokidar-cli",
-- 		"src/**/*",
-- 		"-c",
-- 		`lune run build -- --target {target} --output {output}`,
-- 	})
-- end
