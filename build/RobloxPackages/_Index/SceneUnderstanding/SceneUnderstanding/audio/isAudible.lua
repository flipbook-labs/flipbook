local Root = script:FindFirstAncestor("SceneUnderstanding")

local calculatePotentialAudibility = require(Root.audio.calculatePotentialAudibility)

-- This is an experimentally-determined reasonable threshold of audibility
local AUDIBLE_VOLUME_THRESHOLD = 0.01

--[=[
	Checks if the given audio source can be heard by the client.

	This function supports [Sound] and [AudioPlayer] instances.

	For [Sound] instances, it returns `false` if [UserGameSettings.MasterVolume]
	or [Sound.RollOffGain] are inaccessible.

	@within SceneUnderstanding
	@tag internal
]=]
local function isAudible(audioSource: AudioPlayer | Sound)
	local volume = calculatePotentialAudibility(audioSource)
	return volume > AUDIBLE_VOLUME_THRESHOLD
end

return isAudible
