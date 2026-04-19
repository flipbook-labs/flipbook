--[[
	Computes new grow ratios for the two panels adjacent to a separator when
	the separator is dragged by `delta` pixels.

	`availablePx`        — total group size minus all separator pixel widths
	`beforeRatio`        — current grow ratio of the "before" panel
	`afterRatio`         — current grow ratio of the "after" panel
	`beforeConstraints`  — optional pixel constraints for the before panel
	`afterConstraints`   — optional pixel constraints for the after panel

	Returns (newBeforeRatio, newAfterRatio). The sum of the two returned values
	always equals beforeRatio + afterRatio, so total weight is preserved.
]]
local function computeDraggedSizes(
	availablePx: number,
	delta: number,
	beforeRatio: number,
	afterRatio: number,
	beforeConstraints: NumberRange?,
	afterConstraints: NumberRange?
): (number, number)
	if availablePx <= 0 then
		return beforeRatio, afterRatio
	end

	local totalRatio = beforeRatio + afterRatio
	local totalPx = totalRatio / 100 * availablePx

	local beforePx = beforeRatio / 100 * availablePx
	local newBeforePx = beforePx + delta

	local beforeMin = if beforeConstraints then beforeConstraints.Min else nil
	local beforeMax = if beforeConstraints then beforeConstraints.Max else nil
	local afterMin = if afterConstraints then afterConstraints.Min else nil
	local afterMax = if afterConstraints then afterConstraints.Max else nil

	-- Clamp before panel
	newBeforePx = math.clamp(newBeforePx, beforeMin or 0, beforeMax or math.huge)
	-- Clamp by after panel minimum (before can't take space below afterMin)
	newBeforePx = math.clamp(newBeforePx, 0, totalPx - (afterMin or 0))
	-- Clamp by after panel maximum (before can't shrink after below afterMax)
	if afterMax then
		newBeforePx = math.max(newBeforePx, totalPx - afterMax)
	end

	local newBeforeRatio = newBeforePx / availablePx * 100
	local newAfterRatio = totalRatio - newBeforeRatio

	return newBeforeRatio, newAfterRatio
end

return computeDraggedSizes
