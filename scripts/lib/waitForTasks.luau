local task = require("@lute/task")

local function waitForTasks(tasks: { thread })
	local running = table.clone(tasks)
	while #running > 0 do
		for index, job in running do
			if coroutine.status(job) == "dead" then
				table.remove(running, index)
			end
		end
		task.wait(1 / 30)
	end
end

return waitForTasks
