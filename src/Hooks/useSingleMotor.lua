local Flipper = require(script.Parent.Parent.Packages.Flipper)

local function useSingleMotor(hooks, initialValue)
	local motor = hooks.useValue(Flipper.SingleMotor.new(initialValue)).value
	local binding, setBinding = hooks.useBinding(motor:getValue())

	hooks.useEffect(function()
		motor:onStep(setBinding)
	end, {})

	local function setGoal(goal)
		motor:setGoal(goal)
	end

	return binding, setGoal, motor
end

return useSingleMotor
