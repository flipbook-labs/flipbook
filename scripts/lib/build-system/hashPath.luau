local crypto = require("@lute/crypto")
local fs = require("@lute/fs")

local HASH_METHOD = crypto.hash.md5

local function bufferToHex(buf: buffer): string
	local hex = ""
	for i = 0, buffer.len(buf) - 1 do
		hex ..= ("%02x"):format(buffer.readu8(buf, i))
	end
	return hex
end

local function hashFile(filePath: string): string
	local handle = fs.open(filePath, "r")
	local content = fs.read(handle)
	fs.close(handle)

	return bufferToHex(crypto.digest(HASH_METHOD, content))
end

local function hashDir(dirPath: string): string
	local hashes = {}

	for _, file in fs.listdir(dirPath) do
		local filePath = `{dirPath}/{file.name}`

		if file.type == "dir" then
			table.insert(hashes, hashDir(filePath))
		else
			table.insert(hashes, hashFile(filePath))
		end
	end

	local joinedHash = table.concat(hashes, "")

	return bufferToHex(crypto.digest(HASH_METHOD, joinedHash))
end

local function hashPath(path: string): string
	assert(fs.exists(path), `no file found at {path}`)

	if fs.type(path) == "dir" then
		return hashDir(path)
	else
		return hashFile(path)
	end
end

return hashPath
