local createRunner = require("./util/createRunner")
local wallyInstall = require("./wally-install")

local run = createRunner()

run("foreman", { "install" })
wallyInstall()
