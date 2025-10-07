local RunService = game:GetService("RunService")

local Promise = require(script.Parent.Promise)
local Signal = require(script.Parent.Signal)
local Animation = require(script.Parent.Animation)
local AnimationConfig = require(script.Parent.AnimationConfig)
local util = require(script.Parent.util)
local helpers = require(script.Parent.helpers)

local SpringValue = {}
SpringValue.__index = SpringValue

export type SpringValueProps = {
	from: number,
	to: number,
	delay: number?,
	immediate: boolean?,
	config: AnimationConfig.SpringConfigs?,
	onChange: (position: number) -> ()?,
}

function SpringValue.new(props: SpringValueProps, key: string)
	assert(props.from or props.to, "`to` or `from` expected, none passed.")

	return setmetatable({
		-- The animation state
		animation = Animation.new(props, key),

		-- Some props have customizable default values
		defaultProps = {
			immediate = if props.immediate ~= nil then props.immediate else false,
			config = props.config,
		},

		onChange = props.onChange or function() end,
		onComplete = Signal.new(),

		_memoizedDuration = 0,

		-- When true, this spring has been animated at least once
		hasAnimated = false,
	}, SpringValue)
end

function SpringValue:start(props)
	self.hasAnimated = true
	return self:_update(props)
end

function SpringValue:_update(props)
	if props.default then
		self.defaultProps = util.merge(self.defaultProps, helpers.getDefaultProps(props))
	end

	return Promise.new(function(resolve, _, onCancel)
		if props.delay then
			task.wait(props.delay)
		end

		if onCancel() then
			return
		end

		local range = self:_prepareNode(props)
		local from = range.from
		local to = range.to

		-- Focus the "from" value if changing without a "to" value
		if from and not to then
			to = from
		end

		local anim = self.animation
		local defaultProps = self.defaultProps

		anim:mergeProps(util.merge(defaultProps, props))

		if props.reverse then
			anim.toValues, anim.fromValues = anim.fromValues, anim.toValues
		end
		self.onChange = props.onChange or self.onChange

		--[[
            When `reset` is undefined, the `from` prop implies `reset: true`,
            except for declarative updates. When `reset` is defined, there
            must exist a value to animate from.
        ]]
		local reset = if props.reset == nil then from ~= nil else anim.fromValues ~= nil and props.reset

		if reset then
			anim.values = table.clone(anim.fromValues)
			anim.lastPosition = if from then helpers.getValuesFromType(from) else anim.lastPosition

			local length = #anim.v0
			anim.v0 = table.create(length, nil)
			anim.lastVelocity = table.create(length, nil)
		end

		anim.toValues = helpers.getValuesFromType(to)
		anim.fromValues = table.clone(anim.lastPosition)

		if not self._connection then
			self._connection = RunService.RenderStepped:Connect(function(dt)
				self:advance(dt)
			end)
		end

		self.onComplete:Wait()
		resolve()
	end)
end

function SpringValue:stop()
	self:_disconnect()

	-- TODO: Cancel delayed updates

	self.animation:stop()
end

function SpringValue:pause()
	self:_disconnect()

	-- TODO: Pause delayed updates in time
end

function SpringValue:advance(dt: number)
	local idle = true
	local changed = false

	local anim = self.animation
	local config = anim.config
	local toValues = anim.toValues

	for i, _ in ipairs(anim.values) do
		if anim.done[i] then
			continue
		end

		local finished = anim.immediate
		local position = toValues[i]
		local from = anim.fromValues[i]
		local to = anim.toValues[i]

		if not finished then
			position = anim.lastPosition[i]

			-- Loose springs never move
			if config.tension <= 0 then
				anim.done[i] = true
				continue
			end

			anim.elapsedTime[i] += dt
			local elapsed = anim.elapsedTime[i]

			if anim.v0[i] == nil then
				if typeof(config.velocity) == "table" then
					anim.v0[i] = config.velocity[i]
				else
					-- If a number, set velocity towards the target
					anim.v0[i] = if to - from > 0 then config.velocity elseif to - from < 0 then -config.velocity else 0
				end
			end
			local _v0 = anim.v0[i]

			local velocity

			if config.duration then
				-- Duration easing
				local p = 1

				if config.duration > 0 then
					--[[
                        Here we check if the duration has changed in the config
                        and if so update the elapsed time to the percentage
                        of completition so there is no jank in the animation
                    ]]
					if self._memoizedDuration ~= config.duration then
						-- Update the memoized version to the new duration
						self._memoizedDuration = config.duration

						-- If the value has started animating we need to update it
						if anim.durationProgress[i] > 0 then
							-- Set elapsed time to be the same percentage of progress as the previous duration
							anim.elapsedTime[i] = config.duration * anim.durationProgress[i]
							-- Add the delta so the below updates work as expected
							anim.elapsedTime[i] += dt
							elapsed = anim.elapsedTime[i]
						end
					end

					-- Calculate the new progress
					p = (config.progress or 0) + elapsed / self._memoizedDuration
					-- p is clamped between 0-1
					p = if p > 1 then 1 elseif p < 0 then 0 else p
					-- Store our new progress
					anim.durationProgress[i] = p
				end

				position = from + config.easing(p) * (to - from)
				velocity = (position - anim.lastPosition[i]) / dt

				finished = p == 1
			else
				-- Spring easing
				velocity = anim.lastVelocity[i] or _v0

				local precision = config.precision
					or (if from == to then 0.005 else math.min(1, math.abs(to - from) * 0.001))

				-- DEVIATION: If precision is too low, it will never finish
				precision = math.max(0.0001, precision)

				-- The velocity at which movement is essentially none
				local restVelocity = config.restVelocity or precision / 10

				-- Bouncing is opt-in (not to be confused with overshooting)
				local bounceFactor = if config.clamp then 0 else config.bounce
				local canBounce = bounceFactor ~= nil

				-- When `true`, the value is increasing over time
				local isGrowing = if from == to then _v0 > 0 else from < to

				local numSteps = math.ceil(dt * 1000 / 2)
				for _ = 0, numSteps do
					local isMoving = math.abs(velocity) > restVelocity

					if not isMoving then
						finished = math.abs(to - position) <= precision
						if finished then
							break
						end
					end

					if canBounce then
						local isBouncing = position == to or position > to == isGrowing

						-- Invert the velocity with a magnitude, or clamp it
						if isBouncing then
							velocity = -velocity * bounceFactor
							position = to
						end
					end

					local springForce = -config.tension * 0.000001 * (position - to)
					local dampingForce = -config.friction * 0.001 * velocity
					local acceleration = (springForce + dampingForce) / config.mass -- pt/ms^2

					velocity = velocity + acceleration -- pt/ms
					position = position + velocity
				end
			end

			anim.lastVelocity[i] = velocity
		end

		if finished then
			-- Set position to target value due to precision
			position = to
			anim.done[i] = true
		else
			idle = false
		end

		if anim:setValue(i, position) then
			changed = true
		end
	end

	if idle then
		self.onChange(anim:getValue())
		self:_disconnect()
		self.animation:stop()
		self.onComplete:Fire()
	elseif changed then
		self.onChange(anim:getValue())
	end
end

--[[
    Parse the `to` and `from` range from the given `props` object.

    This also ensures the initial value is available to animated components
    during the render phase.
]]
function SpringValue:_prepareNode(props)
	local key = self.key or ""

	local to = props.to
	local from = props.from

	if typeof(to) == "table" then
		to = to[key]
	end
	if typeof(from) == "table" then
		from = from[key]
	end

	local range = {
		to = to,
		from = from,
	}

	if not self.hasAnimated then
		if props.reverse then
			to, from = from, to
		end

		local values = helpers.getValuesFromType(from or to)
		self.animation = self.animation or Animation.new(#values)
		self.animation.values = table.clone(values)
		self.animation.lastPosition = table.clone(values)
		self.onChange(from or to)
	end

	return range
end

function SpringValue:_disconnect()
	if self._connection then
		self._connection:Disconnect()
		self._connection = nil
	end
end

return SpringValue
