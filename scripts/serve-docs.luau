local run = require("@scripts/lib/run")

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
