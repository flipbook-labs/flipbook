local function getBuildInfo(): { version: string, channel: string, hash: string }
	return {
		version = _G.BUILD_VERSION,
		channel = _G.BUILD_CHANNEL,
		hash = _G.BUILD_HASH,
	}
end

return getBuildInfo
