export type TelemetryEvent = {
	eventName: string,
}

export type TelemetryOptedIn = TelemetryEvent & {
	eventName: "TelemetryOptedIn",
}

export type TelemetryOptedOut = TelemetryEvent & {
	eventName: "TelemetryOptedOut",
}

export type NodePinned = TelemetryEvent & {
	eventName: "NodePinned",
	type: "storybook",
}
export type NodeUnpinned = TelemetryEvent & {
	eventName: "NodeUnpinned",
	type: "storybook",
}

export type SessionStarted = TelemetryEvent & {
	eventName: "SessionStarted",
}

export type SessionEnded = TelemetryEvent & {
	eventName: "SessionEnded",
}

export type StoryOpened = TelemetryEvent & {
	eventName: "StoryOpened",
}

export type StoryClosed = TelemetryEvent & {
	eventName: "StoryClosed",
}

export type Navigated = TelemetryEvent & {
	eventName: "Navigated",
	page: string,
}

return nil
