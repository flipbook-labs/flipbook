local run = require("./lib/run")

run("wally", { "install" })
run("rojo", { "sourcemap", "build.project.json", "-o", "sourcemap.json" })
run("wally-package-types", { "--sourcemap", "sourcemap.json", "Packages" })

run("curl", {
	"-o",
	"Packages/Luaup.luau",
	"https://raw.githubusercontent.com/jackdotink/luaup/bafd3407f750e34a68113b4a894a33c2a2bbe3c1/lib.luau",
})
