local run = require("./lib/run")

run("wally", { "install" })
run("rojo", { "sourcemap", "build.project.json", "-o", "sourcemap.json" })
run("wally-package-types", { "--sourcemap", "sourcemap.json", "Packages" })
