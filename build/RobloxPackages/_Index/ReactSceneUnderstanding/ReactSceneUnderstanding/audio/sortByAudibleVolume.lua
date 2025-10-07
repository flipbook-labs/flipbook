local Root = script:FindFirstAncestor("ReactSceneUnderstanding")

local Cryo = require(Root.Parent.Cryo)
local SceneUnderstanding = require(Root.Parent.SceneUnderstanding)

local function sortByAudibleVolume(audioSources: { AudioPlayer | Sound })
	local audibleSounds = Cryo.List.filter(audioSources, SceneUnderstanding.isAudible)

	return Cryo.List.sort(audibleSounds, function(a: Sound, b: Sound)
		return SceneUnderstanding.calculatePotentialAudibility(a) > SceneUnderstanding.calculatePotentialAudibility(b)
	end)
end

return sortByAudibleVolume
