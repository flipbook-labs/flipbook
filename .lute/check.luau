local FlipbookBatteries = require("@lpm/flipbook-batteries@v0.13.1")
local path = require("@std/path")
local system = require("@std/system")

local run = FlipbookBatteries.run

run("changewrite", { "check", "--fix" })
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
