local Packages = script.Parent.Parent.Parent
local LuauPolyfill = require(Packages.LuauPolyfill)
local Array = LuauPolyfill.Array

local function getSceneIndicesForInterpolationInputRange(props)
	local scene = props.scene
	local scenes = props.scenes

	local index = scene.index
	local lastSceneIndexInScenes = #scenes
	local isBack = not scenes[lastSceneIndexInScenes].isActive

	if isBack then
		local currentSceneIndexInScenes = Array.indexOf(scenes, scene)

		local targetSceneIndexInScenes = nil
		for i, iScene in scenes do
			if iScene.isActive then
				targetSceneIndexInScenes = i
				break
			end
		end

		local targetSceneIndex = scenes[targetSceneIndexInScenes].index
		local lastSceneIndex = scenes[lastSceneIndexInScenes].index

		if index ~= targetSceneIndex and currentSceneIndexInScenes == lastSceneIndexInScenes then
			return {
				first = math.min(targetSceneIndex, index - 1),
				last = index + 1,
			}
		elseif index == targetSceneIndex and currentSceneIndexInScenes == targetSceneIndexInScenes then
			return {
				first = index - 1,
				last = math.max(lastSceneIndex, index + 1),
			}
		elseif index == targetSceneIndex or currentSceneIndexInScenes > targetSceneIndexInScenes then
			return nil
		end
	end

	return {
		first = index - 1,
		last = index + 1,
	}
end

return getSceneIndicesForInterpolationInputRange
