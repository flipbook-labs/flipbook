local deferredModeEnabled = _G.__SIGNALS_DEFERRED_MODE_ENABLED__ or _G.__DEV__

local isContinuing = false

local continuations: { () -> () } = {}

local function scheduleWork(work: () -> ())
	table.insert(continuations, work)
end

local function runContinuations()
	if not deferredModeEnabled then
		if not isContinuing then
			isContinuing = true
			for _, work in continuations do
				work()
			end
			table.clear(continuations)
			isContinuing = false
		end
	end
end

return {
	scheduleWork = if deferredModeEnabled then task.defer else scheduleWork :: never,
	runContinuations = if deferredModeEnabled then function() end else runContinuations :: never,
}
