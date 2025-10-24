local Sift = require("@pkg/Sift")

local defaultOptions = {
	waitMs = 100,
	timeoutMs = 5000,
}

type Options = {
	-- Default: 1000
	waitMs: number?,

	-- Default: 5000
	timeoutMs: number?,
}

type JoinedOptions = Options & typeof(defaultOptions)

local function waitForAsync(callback: () -> boolean, options: Options?)
	local joinedOptions: JoinedOptions = Sift.Dictionary.join(defaultOptions, options)

	local elapsed = 0
	local err
	repeat
		elapsed += task.wait(joinedOptions.waitMs / 1000)
		local success
		local result

		success, err = pcall(function()
			result = callback()
		end)

		if success and result then
			return result
		end
	until elapsed >= joinedOptions.timeoutMs / 1000

	error(err)
end

return waitForAsync
