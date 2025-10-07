local validationEnabled = _G.__SIGNALS_VALIDATION_ENABLED__ or _G.__DEV__

local function handleNoYieldValidation(co: thread, ok: boolean, ...)
	if not ok then
		local err = (...)
		if typeof(err) == "string" then
			error(debug.traceback(co, err), 2)
		else
			error(tostring(err), 2)
		end
	end

	if coroutine.status(co) ~= "dead" then
		error(debug.traceback(co, "Attempted to yield!"), 2)
	end

	return ...
end

local function callWithValidation<Args..., Rets...>(fn: (Args...) -> Rets..., ...: Args...): Rets...
	local co = coroutine.create(fn)
	return handleNoYieldValidation(co, coroutine.resume(co, ...))
end

local function callWithoutValidation<Args..., Rets...>(fn: (Args...) -> Rets..., ...: Args...): Rets...
	return fn(...)
end

return if validationEnabled then callWithValidation else callWithoutValidation :: never
