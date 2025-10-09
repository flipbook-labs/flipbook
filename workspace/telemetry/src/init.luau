local types = require("@self/types")

export type TelemetryOptedIn = types.TelemetryOptedIn
export type TelemetryOptedOut = types.TelemetryOptedOut
export type NodePinned = types.NodePinned
export type SessionStarted = types.SessionStarted
export type SessionEnded = types.SessionEnded
export type StoryOpened = types.StoryOpened
export type StoryClosed = types.StoryClosed
export type Navigated = types.Navigated

return {
	fireEvent = require("@self/fireEvent"),
}
