local FlipbookBatteries = require("@luaupkg/flipbook-batteries@v0.12.0")
local path = require("@std/path")
local system = require("@std/system")

local run = FlipbookBatteries.run

run("lute", { "setup" })
run("lute", { "run", "lint" })
run("lute", { "run", "analyze" })
run("lute", {
	"run",
	"build",
	"plugin",
	"--channel",
	"dev",
	"--clean",
	"--skip-reload",
	"--output",
	tostring(path.join(system.tmpdir(), "flipbook-check.rbxm")),
})
