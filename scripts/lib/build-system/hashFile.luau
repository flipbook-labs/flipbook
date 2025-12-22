local crypto = require("@lute/crypto")
local fs = require("@lute/fs")

local function hashFile(filePath: string): string
	local handle = fs.open(filePath, "r")
	local content = fs.read(handle)
	fs.close(handle)
	return buffer.tostring(crypto.digest(crypto.hash.md5, content))
end

return hashFile
