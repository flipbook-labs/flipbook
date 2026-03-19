local FlipbookBatteries = require("@luaupkg/flipbook-batteries")

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
