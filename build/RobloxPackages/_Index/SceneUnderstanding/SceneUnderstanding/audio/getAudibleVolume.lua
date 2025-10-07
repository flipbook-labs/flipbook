local Root = script:FindFirstAncestor("SceneUnderstanding")

local UserGameSettings = UserSettings():GetService("UserGameSettings")

local safelyAccessProperty = require(Root.safelyAccessProperty)

--[=[
	Determines the threshold of how audible an audio is to the current client.

	Returns 0 if [UserGameSettings.MasterVolume] or [Sound.RollOffGain] are inaccessible

	This function is deprecated in favor of [SceneUnderstanding.calculatePotentialAudibility]
	which supports the new Audio API.

	@within SceneUnderstanding
	@tag internal
	@deprecated v0.8.0 -- Use calculatePotentialAudibility which supports the new Audio API.
]=]
local function getAudibleVolume(sound: Sound): number
	if not sound.IsPlaying then
		return 0
	end

	-- These properties are integral to determining audibility but are not
	-- accessible in lower security levels. To ensure we don't accidentally
	-- lie about how audible something is we simply zero them out
	local masterVolume = safelyAccessProperty(UserGameSettings, "MasterVolume", 0)
	local rollOffGain = safelyAccessProperty(sound, "RollOffGain", 0)

	local groupVolume = if sound.SoundGroup then sound.SoundGroup.Volume else 1

	-- TODO MUS-1159: Add PlaybackLoudness as a factor for audibility. It looks
	-- to considerably increase accuracy
	return masterVolume * groupVolume * sound.Volume * rollOffGain
end

return getAudibleVolume
