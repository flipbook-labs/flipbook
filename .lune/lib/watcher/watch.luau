local fs = require("@lune/fs")
local stdio = require("@lune/stdio")
local task = require("@lune/task")

local diffArray = require("./diffArray")
local getWatchedFiles = require("./getWatchedFiles")
local maybeCall = require("./maybeCall")

type FileChanges = { string }

type Options = {
	filePatterns: { string },
	onAdded: ((changedFiles: FileChanges) -> ())?,
	onRemoved: ((changedFiles: FileChanges) -> ())?,
	onChanged: ((changedFiles: FileChanges) -> ())?,
}

local function watch(options: Options)
	local prevWatchedFileMetadata: { [string]: string } = {}
	local watchedFiles = getWatchedFiles(options.filePatterns)
	local prevWatchedFiles

	print("watching files:")
	stdio.write(stdio.style("dim"))
	for _, watchedFile in watchedFiles do
		print(`> {watchedFile}`)
	end
	stdio.write(stdio.style("reset"))
	print("listening for file changes...")

	-- FIXME: Ctrl+C doesn't cancel the loop. Is this a Lune bug or a Foreman bug?
	while true do
		local changedFiles: FileChanges = {}

		if prevWatchedFiles and #watchedFiles ~= #prevWatchedFiles then
			changedFiles = diffArray(prevWatchedFiles, watchedFiles)

			if #watchedFiles > #prevWatchedFiles then
				maybeCall(options.onAdded, changedFiles)
			elseif #watchedFiles < #prevWatchedFiles then
				maybeCall(options.onRemoved, changedFiles)

				for _, filePath in changedFiles do
					prevWatchedFileMetadata[filePath] = nil
				end
			end
		end

		for _, watchedFile in watchedFiles do
			local metadata = fs.metadata(watchedFile)

			local prevMetadata = prevWatchedFileMetadata[watchedFile]
			if prevMetadata and metadata.modifiedAt > prevMetadata.modifiedAt then
				table.insert(changedFiles, watchedFile)
			end

			prevWatchedFileMetadata[watchedFile] = metadata
		end

		if #changedFiles > 0 then
			maybeCall(options.onChanged, changedFiles)
		end

		prevWatchedFiles = watchedFiles
		task.wait(1)
		watchedFiles = getWatchedFiles(options.filePatterns)
	end
end

return watch
