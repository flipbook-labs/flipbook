local crypto = require("@lute/crypto")
local fs = require("@lute/fs")

local function hashFile(filePath: string): string
	local content = fs.readfiletostring(filePath)
	return buffer.tostring(crypto.digest(crypto.hash.md5, content))
end

return hashFile
