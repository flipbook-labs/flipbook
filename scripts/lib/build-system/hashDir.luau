local crypto = require("@lute/crypto")
local fs = require("@lute/fs")

local hashFile = require("./hashFile")

local function hashDir(dirPath: string): string
	local fileHashes = ""

	for _, file in fs.listdir(dirPath) do
		local filePath = `{dirPath}/{file.name}`

		if file.type == "dir" then
			fileHashes ..= hashDir(filePath)
		else
			fileHashes ..= hashFile(filePath)
		end
	end

	return buffer.tostring(crypto.digest(crypto.hash.md5, fileHashes))
end

return hashDir
