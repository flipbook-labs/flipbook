local Root = script:FindFirstAncestor("ReactSceneUnderstanding")

local SoundService = game:GetService("SoundService")

local Cryo = require(Root.Parent.Cryo)
local React = require(Root.Parent.React)
local useTimedLoop = require(Root.useTimedLoop)

local useState = React.useState

local AUTO_REFRESH_SECONDS = 1

local function getAllAudioSources(): { AudioPlayer | Sound }
	-- This method was introduced in 645, and lua-apps currently runs tests
	-- against 641+. To allow tests to pass we need to ensure this method is
	-- guarded so attempts to use it on older versions will not cause an error.
	--
	-- This pcall can be be removed once the oldest version lua-apps runs
	-- against is 645,
	local success, results = pcall(function()
		return SoundService:GetAudioInstances()
	end)

	if success then
		return Cryo.List.filter(results, function(instance: Instance)
			return instance:IsA("Sound") or instance:IsA("AudioPlayer")
		end)
	else
		return {}
	end
end

local function useAudioSources(): { AudioPlayer | Sound }
	local audioSources, setAudioSources = useState(getAllAudioSources)

	useTimedLoop(AUTO_REFRESH_SECONDS, function()
		setAudioSources(getAllAudioSources())
	end)

	return audioSources
end

return useAudioSources
