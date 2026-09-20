export type ConsentState = "Unknown" | "Granted" | "Denied"
export type ConsentDecision = "Granted" | "Denied"

return table.freeze({
	Unknown = "Unknown" :: "Unknown",
	Granted = "Granted" :: "Granted",
	Denied = "Denied" :: "Denied",
})
