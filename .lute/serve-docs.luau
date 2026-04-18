local FlipbookBatteries = require("@luaupkg/flipbook-batteries@v0.9.0")

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
