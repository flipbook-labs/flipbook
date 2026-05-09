local FlipbookBatteries = require("@luaupkg/FlipbookBatteries@v0.10.1")

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
