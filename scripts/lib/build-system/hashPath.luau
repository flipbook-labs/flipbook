local crypto = require("@lute/crypto")
local fs = require("@std/fs")
local path = require("@std/path")

local HASH_METHOD = crypto.hash.md5

local function bufferToHex(buf: buffer): string
	local hex = ""
	for i = 0, buffer.len(buf) - 1 do
		hex ..= ("%02x"):format(buffer.readu8(buf, i))
	end
	return hex
end

local function hashFile(filePath: path.pathlike): string
	local content = fs.readfiletostring(filePath)
	return bufferToHex(crypto.digest(HASH_METHOD, content))
end

local function hashDir(dirPath: string): string
	local hashes = {}

	for _, file in fs.listdirectory(dirPath) do
		local filePath = path.join(dirPath, file.name)

		if file.type == "dir" then
			table.insert(hashes, hashDir(filePath))
		else
			table.insert(hashes, hashFile(filePath))
		end
	end

	local joinedHash = table.concat(hashes, "")

	return bufferToHex(crypto.digest(HASH_METHOD, joinedHash))
end

local function hashPath(filePath: path.pathlike): string
	assert(fs.exists(filePath), `no file found at {filePath}`)

	if fs.type(filePath) == "dir" then
		return hashDir(filePath)
	else
		return hashFile(filePath)
	end
end

return hashPath
