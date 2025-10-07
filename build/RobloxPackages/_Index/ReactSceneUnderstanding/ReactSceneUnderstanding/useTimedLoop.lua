local Root = script:FindFirstAncestor("ReactSceneUnderstanding")

local React = require(Root.Parent.React)

local useEffect = React.useEffect

local function useTimedLoop(delaySeconds: number, callback: () -> ())
	useEffect(function()
		local isRunning = true

		task.spawn(function()
			while isRunning do
				task.wait(delaySeconds)

				if not isRunning then
					break
				end

				callback()
			end
		end)

		return function()
			isRunning = false
		end
	end, { delaySeconds, callback } :: { unknown })
end

return useTimedLoop
