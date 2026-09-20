local ConsentState = require("@root/ConsentState")

export type ConsentState = ConsentState.ConsentState
export type ConsentDecision = ConsentState.ConsentDecision

-- Event names and properties mirror the backend telemetry contract. Update the
-- backend before extending this union.
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

export type FeedbackDialogOpened = {
	eventName: "FeedbackDialogOpened",
}

export type FeedbackSubmitted = {
	eventName: "FeedbackSubmitted",
}

export type FeedbackDiscarded = {
	eventName: "FeedbackDiscarded",
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
	| FeedbackDialogOpened
	| FeedbackSubmitted
	| FeedbackDiscarded

export type TelemetryEventName =
	"AppOpened"
	| "AppClosed"
	| "NodePinned"
	| "NodeUnpinned"
	| "PageChanged"
	| "StoryClosed"
	| "StoryOpened"
	| "TelemetryOptedIn"
	| "TelemetryOptedOut"
	| "FeedbackDialogOpened"
	| "FeedbackSubmitted"
	| "FeedbackDiscarded"

export type TelemetryEnvelope = {
	eventName: TelemetryEventName,
	properties: { page: string }?,
	anonymizedUserId: string,
	buildVersion: string,
	buildChannel: string,
	buildHash: string,
}

export type TelemetryContext = {
	buildVersion: string,
	buildChannel: string,
	buildHash: string,
}

export type TelemetryStorage = {
	read: () -> unknown,
	write: (value: string) -> (),
}

export type TelemetryOptions = {
	context: TelemetryContext,
	disabled: boolean?,
	legacyConsent: ConsentState?,
	storage: TelemetryStorage?,
	transport: (envelope: TelemetryEnvelope) -> (),
}

export type TelemetryClient = {
	capture: (event: TelemetryEvent) -> boolean,
	getConsent: () -> ConsentState,
	setConsent: (consent: ConsentDecision) -> (),
}

return nil
