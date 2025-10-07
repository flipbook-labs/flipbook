local Object = require(script.Parent:WaitForChild('collections')).Object

local makeTimerImpl = require(script:WaitForChild('makeTimerImpl'))
local makeIntervalImpl = require(script:WaitForChild('makeIntervalImpl'))

export type Timeout = makeTimerImpl.Timeout
export type Interval = makeIntervalImpl.Interval

return Object.assign({}, makeTimerImpl(task.delay), makeIntervalImpl(task.delay))
