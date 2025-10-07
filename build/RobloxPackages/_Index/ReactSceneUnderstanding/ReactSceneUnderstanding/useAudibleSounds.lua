local Root = script:FindFirstAncestor("ReactSceneUnderstanding")

local React = require(Root.Parent.React)
local ReactUtils = require(Root.Parent.ReactUtils)
local SceneAnalysisContext = require(Root.SceneAnalysisContext)
local enums = require(Root.enums)
local useCameraState = require(Root.useCameraState)
local sortByAudibleVolume = require(Root.audio.sortByAudibleVolume)
local useAudioSources = require(Root.audio.useAudioSources)
local useTimedLoop = require(Root.useTimedLoop)

local AUTO_REFRESH_SECONDS = 1

local useCallback = React.useCallback
local useEffect = React.useEffect
local usePrevious = ReactUtils.usePrevious

--[=[
	Returns an array of audio sources sorted by how audible they are relative to
	the client. Any instances determined to be inaudible are omitted.

	This function supports [Sound] and [AudioPlayer] instances.

	```lua
	local audioSources = useAudibleSounds()
	```

	@within ReactSceneUnderstanding
	@tag internal
]=]
local function useAudibleSounds(): { AudioPlayer | Sound }
	local sceneAnalysis = SceneAnalysisContext.use()
	local audioSources = useAudioSources()
	local cameraState = useCameraState()
	local prevCameraState = usePrevious(cameraState)

	local updateAudibleSounds = useCallback(function()
		sceneAnalysis.setAudibleSounds(sortByAudibleVolume(audioSources))
	end, { audioSources, sceneAnalysis.setAudibleSounds } :: { unknown })

	--[[
		In the past we called updateAudibleSounds each time certain properties
		of Sound and Audio instances changed. The goal was to make
		useAudibleSounds as snappy as possible, but this resulted in significant
		FPS drops in production experiences. So instead we simply rely on
		polling.

		Read more here:
		https://roblox.atlassian.net/wiki/spaces/MUS/pages/3375399016/What+s+Playing+Experiment+Deallocation+and+Investigation

		It would be entirely feasible to listen for property changes again and
		throttle state updates to get the best of both worlds, but there's
		currently no pressing business need to have immediate updates, so
		polling is just fine
	]]
	useTimedLoop(AUTO_REFRESH_SECONDS, function()
		updateAudibleSounds()
	end)

	useEffect(function()
		if #sceneAnalysis.audibleSounds == 0 and #audioSources > 0 then
			updateAudibleSounds()
		end
	end, { #sceneAnalysis.audibleSounds, #audioSources, updateAudibleSounds } :: { unknown })

	useEffect(function()
		if cameraState ~= prevCameraState and cameraState == enums.CameraState.Idle then
			updateAudibleSounds()
		end
	end, { cameraState, prevCameraState, updateAudibleSounds } :: { unknown })

	return sceneAnalysis.audibleSounds
end

return useAudibleSounds
