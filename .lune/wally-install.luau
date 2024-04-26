local run = require("./util/run")

local PACKAGES_PATH = "Packages"
local PROJECT_PATH = "build.project.json"
local SOURCEMAP_PATH = "sourcemap.json"

run("wally", { "install" })
run("rojo", { "sourcemap", PROJECT_PATH, "-o", SOURCEMAP_PATH })
run("wally-package-types", { "--sourcemap", SOURCEMAP_PATH, PACKAGES_PATH })
