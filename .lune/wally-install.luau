local installPackages = require("./lib/installPackages")

local PACKAGES_PATH = "Packages"
local PROJECT_PATH = "build.project.json"
local SOURCEMAP_PATH = "sourcemap.json"

installPackages(PROJECT_PATH, SOURCEMAP_PATH, PACKAGES_PATH)
