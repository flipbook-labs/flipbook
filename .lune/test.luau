local process = require("@lune/process")

local clean = require("./lib/clean")
local compile = require("./lib/compile")
local constants = require("./lib/constants")
local run = require("./lib/run")
local setFlags = require("./lib/setFlags")

clean()
setFlags(process.os)
compile("dev")

run("rojo", { "build", constants.ROJO_TESTS_PROJECT, "-o", "test-place.rbxl" })
run("run-in-roblox", { "--place", "test-place.rbxl", "--script", "tests/run-tests.luau" })
