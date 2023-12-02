export type ScriptAnalysisRequest = {
	["script"]: LuaSourceContainer,
}

type ScriptAnalysisDiagnostic = {
	range: {
		start: {
			line: number,
			character: number,
		},
		["end"]: {
			line: number,
			character: number,
		},
	},
	code: string?,
	message: string,
	severity: Enum.Severity?,
	codeDescription: { href: string }?,
}

export type ScriptAnalysisResponse = {
	diagnostics: { ScriptAnalysisDiagnostic },
}

return nil
