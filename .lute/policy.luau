local runPolicy = require("@scripts/lib/policy/runPolicy")

local arguments = { ... }
table.remove(arguments, 1)
runPolicy(arguments)
