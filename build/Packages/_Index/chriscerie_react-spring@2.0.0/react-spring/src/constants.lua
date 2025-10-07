local constants = {}

local c1 = 1.70158
local c2 = c1 * 1.525
local c3 = c1 + 1
local c4 = (2 * math.pi) / 3
local c5 = (2 * math.pi) / 4.5

constants.config = table.freeze({
	default = table.freeze({ tension = 170, friction = 26 }),
	gentle = table.freeze({ tension = 120, friction = 14 }),
	wobbly = table.freeze({ tension = 180, friction = 12 }),
	stiff = table.freeze({ tension = 210, friction = 20 }),
	slow = table.freeze({ tension = 280, friction = 60 }),
	molasses = table.freeze({ tension = 280, friction = 120 }),
})

local bounceOut = function(x)
	local n1 = 7.5625
	local d1 = 2.75

	if x < 1 / d1 then
		return n1 * x ^ 2
	elseif x < 2 / d1 then
		x -= 1.5 / d1
		return n1 * x ^ 2 + 0.75
	elseif x < 2.5 / d1 then
		x -= -2.25 / d1
		return n1 * x ^ 2 + 0.9375
	else
		x -= -2.625 / d1
		return n1 * x ^ 2 + 0.984375
	end
end

export type EasingFunction = (t: number) -> number

constants.easings = table.freeze({
	linear = function(x)
		return x
	end,
	easeInQuad = function(x)
		return x ^ 2
	end,
	easeOutQuad = function(x)
		return 1 - (1 - x) ^ 2
	end,
	easeInOutQuad = function(x)
		return if x < 0.5 then 2 * x ^ 2 else 1 - (-2 * x + 2) ^ 2 / 2
	end,
	easeInCubic = function(x)
		return x ^ 3
	end,
	easeOutCubic = function(x)
		return 1 - (1 - x) ^ 3
	end,
	easeInOutCubic = function(x)
		return if x < 0.5 then 4 * x ^ 3 else 1 - (-2 * x + 2) ^ 3 / 2
	end,
	easeInQuart = function(x)
		return x ^ 4
	end,
	easeOutQuart = function(x)
		return 1 - (1 - x) ^ 4
	end,
	easeInOutQuart = function(x)
		return if x < 0.5 then 8 * x ^ 4 else 1 - (-2 * x + 2) ^ 4 / 2
	end,
	easeInQuint = function(x)
		return x ^ 5
	end,
	easeOutQuint = function(x)
		return 1 - (1 - x) ^ 5
	end,
	easeInOutQuint = function(x)
		return if x < 0.5 then 16 * x ^ 5 else 1 - (-2 * x + 2) ^ 5 / 2
	end,
	easeInSine = function(x)
		return 1 - math.cos(x * math.pi / 2)
	end,
	easeOutSine = function(x)
		return math.sin(x * math.pi / 2)
	end,
	easeInOutSine = function(x)
		return -(math.cos(math.pi * x) - 1) / 2
	end,
	easeInExpo = function(x)
		return if x == 0 then 0 else 2 ^ (10 * x - 10)
	end,
	easeOutExpo = function(x)
		return if x == 1 then 1 else 1 - 2 ^ (-10 * x)
	end,
	easeInOutExpo = function(x)
		return if x == 0
			then 0
			elseif x == 1 then 1
			elseif x < 0.5 then 2 ^ (20 * x - 10) / 2
			else 2 - 2 ^ (-20 * x + 10) / 2
	end,
	easeInCirc = function(x)
		return 1 - math.sqrt(1 - x ^ 2)
	end,
	easeOutCirc = function(x)
		return math.sqrt(1 - (x - 1) ^ 2)
	end,
	easeInOutCirc = function(x)
		return if x < 0.5 then (1 - math.sqrt(1 - (2 * x) ^ 2)) / 2 else (math.sqrt(1 - (-2 * x + 2) ^ 2) + 1) / 2
	end,
	easeInBack = function(x)
		return c3 * x ^ 3 - c1 * x ^ 2
	end,
	easeOutBack = function(x)
		return 1 + c3 * (x - 1) ^ 3 + c1 * (x - 1) ^ 2
	end,
	easeInOutBack = function(x)
		return if x < 0.5
			then ((2 * x) ^ 2 * ((c2 + 1) * 2 * x - c2)) / 2
			else ((2 * x - 2) ^ 2 * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2
	end,
	easeInElastic = function(x)
		return if x == 0 then 0 elseif x == 1 then 1 else -2 ^ (10 * x - 10) * math.sin((x * 10 - 10.75) * c4)
	end,
	easeOutElastic = function(x)
		return if x == 0 then 0 elseif x == 1 then 1 else 2 ^ (-10 * x) * math.sin((x * 10 - 0.75) * c4) + 1
	end,
	easeInOutElastic = function(x)
		return if x == 0
			then 0
			elseif x == 1 then 1
			elseif x < 0.5 then -(2 ^ (20 * x - 10) * math.sin((20 * x - 11.125) * c5)) / 2
			else (2 ^ (-20 * x + 10) * math.sin((20 * x - 11.125) * c5)) / 2 + 1
	end,
	easeInBounce = function(x)
		return 1 - bounceOut(1 - x)
	end,
	easeOutBounce = bounceOut,
	easeInOutBounce = function(x)
		return if x < 0.5 then (1 - bounceOut(1 - 2 * x)) / 2 else (1 + bounceOut(2 * x - 1)) / 2
	end,
})

return constants
