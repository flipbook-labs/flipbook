local process = require("@lute/process")
local richterm = require("@luaupkg/batteries/richterm")

local hashPath = require("@scripts/lib/build-system/hashPath")
local types = require("@scripts/lib/build-system/types")

type BuildGroup = types.BuildGroup

local function trimDecimals(n: number, decmimalPlaces: number)
	local factor = math.pow(10, decmimalPlaces)
	return math.floor(n * factor) / factor
end

local function runBuildGroupAsync(buildGroup: BuildGroup)
	local prefix = richterm.bold(`[{buildGroup.name}]`)
	local buildCache = buildGroup.context.cache
	local changedPaths = {}

	for _, path in buildGroup.paths do
		local hash = hashPath(path)

		if hash ~= buildCache.hashes[path] or buildGroup.context.shouldRebuild then
			buildCache.hashes[path] = hash
			table.insert(changedPaths, path)
		end
	end

	if #changedPaths == 0 then
		return
	end

	local processedBuildGroup = table.clone(buildGroup)
	processedBuildGroup.paths = changedPaths

	print(`{prefix} starting build step...`)

	local startTime = os.clock()
	local ok, err = pcall(function()
		buildGroup.step(processedBuildGroup)
		return nil
	end)

	if ok then
		local elapsedMs = trimDecimals((os.clock() - startTime) * 1000, 3)
		local message = richterm.cyan(`step completed in {elapsedMs}ms`)
		print(`{prefix} {message}`)
	else
		local message = richterm.red(`step failed: {err}`)
		print(`{prefix} {message}`)
		process.exit(1)
	end
end

return runBuildGroupAsync
