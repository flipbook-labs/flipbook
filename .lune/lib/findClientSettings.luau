local run = require("./run")

local function findClientSettings(os: string)
	if os == "macos" then
		return "/Applications/RobloxStudio.app/Contents/MacOS/ClientSettings"
	elseif os == "windows" then
		local robloxStudioPath = run("find", {
			"$LOCALAPPDATA/Roblox/Versions",
			"-name",
			"RobloxStudioBeta.exe",
		})

		local dir = run("dirname", {
			robloxStudioPath,
		})

		return `{dir}/ClientSettings`
	else
		return nil
	end
end

return findClientSettings
