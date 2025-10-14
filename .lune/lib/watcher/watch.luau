local fs = require("@lute/fs")

local getWatchedFiles = require("./getWatchedFiles")

type Options = {
	filePatterns: { string },
	excludedFilePatterns: { string }?,
	onChanged: ((changedFiles: { string }) -> ())?,
}

local function watch(options: Options)
	local watchedFiles = getWatchedFiles(options.filePatterns, options.excludedFilePatterns)

	local handles: { fs.WatchHandle } = {}

	print("watching files:")
	-- stdio.write(stdio.style("dim"))
	for _, watchedFile in watchedFiles do
		print(`> {watchedFile}`)

		table.insert(
			handles,
			fs.watch(watchedFile, function(filename)
				if options.onChanged then
					options.onChanged({ filename })
				end
			end)
		)
	end
	-- stdio.write(stdio.style("reset"))
	print("listening for file changes...")

	while true do
		task.wait(1)
	end
end

return watch
