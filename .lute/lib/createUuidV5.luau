local crypto = require("@lute/crypto")

-- Creates a name-based UUID (version 5, RFC 9562): the same namespace and name
-- always produce the same UUID. `namespace` is itself a UUID string.
local function createUuidV5(namespace: string, name: string): string
	local namespaceHex = namespace:gsub("-", "")
	assert(#namespaceHex == 32 and not namespaceHex:find("%X"), `Invalid namespace UUID: {namespace}`)

	local namespaceBytes = namespaceHex:gsub("%x%x", function(byte)
		return string.char(tonumber(byte, 16) :: number)
	end)
	local digest = crypto.digest(crypto.hash.sha1, namespaceBytes .. name)

	local hex = {}
	for i = 0, 15 do
		local byte = buffer.readu8(digest, i)
		if i == 6 then
			byte = bit32.bor(bit32.band(byte, 0x0f), 0x50)
		elseif i == 8 then
			byte = bit32.bor(bit32.band(byte, 0x3f), 0x80)
		end
		hex[i + 1] = string.format("%02x", byte)
	end

	local text = table.concat(hex)
	return `{text:sub(1, 8)}-{text:sub(9, 12)}-{text:sub(13, 16)}-{text:sub(17, 20)}-{text:sub(21, 32)}`
end

return createUuidV5
