local fs = require("@lute/fs")
-- local task = require("@lute/task")

-- local diffArray = require("./diffArray")
local getWatchedFiles = require("./getWatchedFiles")
local maybeCall = require("./maybeCall")

type FileChanges = { string }

type Options = {
	filePatterns: { string },
	excludedFilePatterns: { string }?,
	onChanged: ((changedFiles: FileChanges) -> ())?,
}

local function watch(options: Options)
	local prevWatchedFileMetadata: { [string]: fs.FileMetadata } = {}
	local watchedFiles = getWatchedFiles(options.filePatterns, options.excludedFilePatterns)
	local prevWatchedFiles

	local function onFileChanged(filename: string, event: fs.WatchEvent)
		if options.onChanged then
			options.onChanged({ filename })
		end
	end

	local handles: { fs.WatchHandle } = {}

	print("watching files:")
	-- stdio.write(stdio.style("dim"))
	for _, watchedFile in watchedFiles do
		print(`> {watchedFile}`)
		table.insert(handles, fs.watch(watchedFile, onFileChanged))
	end
	-- stdio.write(stdio.style("reset"))
	print("listening for file changes...")

	-- -- FIXME: Ctrl+C doesn't cancel the loop. Is this a Lune bug or a Foreman bug?
	-- while true do
	-- 	local changedFiles: FileChanges = {}

	-- 	if prevWatchedFiles and #watchedFiles ~= #prevWatchedFiles then
	-- 		changedFiles = diffArray(prevWatchedFiles, watchedFiles)

	-- 		if #watchedFiles > #prevWatchedFiles then
	-- 			maybeCall(options.onAdded, changedFiles)
	-- 		elseif #watchedFiles < #prevWatchedFiles then
	-- 			maybeCall(options.onRemoved, changedFiles)

	-- 			for _, filePath in changedFiles do
	-- 				prevWatchedFileMetadata[filePath] = nil
	-- 			end
	-- 		end
	-- 	end

	-- 	for _, watchedFile in watchedFiles do
	-- 		local metadata = fs.stat(watchedFile)

	-- 		local prevMetadata = prevWatchedFileMetadata[watchedFile]
	-- 		if prevMetadata and metadata.modified_at > prevMetadata.modified_at then
	-- 			table.insert(changedFiles, watchedFile)
	-- 		end

	-- 		prevWatchedFileMetadata[watchedFile] = metadata
	-- 	end

	-- 	if #changedFiles > 0 then
	-- 		maybeCall(options.onChanged, changedFiles)
	-- 	end

	-- 	prevWatchedFiles = watchedFiles
	-- 	task.wait(1)
	-- 	watchedFiles = getWatchedFiles(options.filePatterns, options.excludedFilePatterns)
	-- end
end

return watch
