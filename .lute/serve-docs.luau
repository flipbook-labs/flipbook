local FlipbookBatteries = require("@lpm/flipbook-batteries@v0.13.1")

local run = FlipbookBatteries.run

run("npm", {
	"install",
}, {
	cwd = "docs/site",
})

run("npm", {
	"start",
}, {
	cwd = "docs/site",
})
