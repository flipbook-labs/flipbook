local FlipbookBatteries = require("@luaupkg/flipbook-batteries@bump-lute-to-1.0.1-nightly")

local run = FlipbookBatteries.run

run("npm", {
	"install",
}, {
	cwd = "docs",
})

run("npm", {
	"start",
}, {
	cwd = "docs",
})
