-- The events in this file mirror the TelementryEventName enum in the backend.
-- The backend must be updated first before adding new events.

export type AppOpened = {
	eventName: "AppOpened",
}

export type AppClosed = {
	eventName: "AppClosed",
}

export type NodePinned = {
	eventName: "NodePinned",
}

export type NodeUnpinned = {
	eventName: "NodeUnpinned",
}

export type PageChanged = {
	eventName: "PageChanged",
	properties: {
		page: string,
	},
}
export type StoryOpened = {
	eventName: "StoryOpened",
}

export type StoryClosed = {
	eventName: "StoryClosed",
}

export type TelemetryOptedIn = {
	eventName: "TelemetryOptedIn",
}

export type TelemetryOptedOut = {
	eventName: "TelemetryOptedOut",
}

export type TelemetryEvent =
	AppOpened
	| AppClosed
	| NodePinned
	| NodeUnpinned
	| PageChanged
	| StoryClosed
	| StoryOpened
	| TelemetryOptedIn
	| TelemetryOptedOut

return nil
