local FlipbookBatteries = require("@luaupkg/flipbook-batteries@v0.11.1")

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
