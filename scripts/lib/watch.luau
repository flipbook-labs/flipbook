local fs = require("@lute/fs")
local process = require("@lute/process")
local richterm = require("@luaupkg/batteries/richterm")
local task = require("@lute/task")

local matchDescendants = require("@scripts/lib/matchDescendants")

type Options = {
	roots: { string },
	excludedFilePatterns: { string }?,
	onChanged: ((changedPath: string) -> ())?,
}

local function watch(options: Options)
	local foldersToWatch = matchDescendants(process.cwd(), function(path): boolean?
		if fs.type(path) == "dir" then
			if options.excludedFilePatterns then
				for _, excludedFilePattern in options.excludedFilePatterns do
					if path:match(excludedFilePattern) then
						return nil
					end
				end
			end

			for _, root in options.roots do
				if path:match(root) then
					return true
				end
			end
		end

		return false
	end)

	print(richterm.dim("watching folders:"))
	for _, watchedFolder in foldersToWatch do
		print(richterm.dim(`> {watchedFolder}`))

		task.spawn(function()
			fs.watch(watchedFolder, function(filename, watchEvent)
				if watchEvent.change and options.onChanged then
					local filePath = `{watchedFolder}/{filename}`
					options.onChanged(filePath)
				end
			end)
		end)
	end
	print("listening for file changes...")

	task.wait(math.huge)
end

return watch
