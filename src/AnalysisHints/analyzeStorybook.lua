local analysisHintsTypes = require("@root/AnalysisHints/types")
local getLineFromTypecheckError = require("@root/AnalysisHints/getLineFromTypecheckError")
local isStorybookModule = require("@root/Storybook/isStorybookModule")
local storybookTypes = require("@root/Storybook/types")

type Storybook = storybookTypes.Storybook
type ScriptAnalysisDiagnostic = analysisHintsTypes.ScriptAnalysisDiagnostic
type ScriptAnalysisResponse = analysisHintsTypes.ScriptAnalysisResponse

local function analyzeStorybook(module: ModuleScript, loader: any): ScriptAnalysisResponse
	local diagnostic: ScriptAnalysisDiagnostic?

	if isStorybookModule(module) then
		local storybook = loader:require(module)
		local success, message = storybookTypes.Storybook(storybook)

		if not success then
			local line = getLineFromTypecheckError(message, module.Source)

			if line then
				diagnostic = {
					range = {
						start = {
							line = line,
							character = 0,
						},
						["end"] = {
							line = line,
							character = math.huge,
						},
					},
					code = "code",
					message = if message then message else "unknown",
					severity = Enum.Severity.Warning,
				}
			end
		end
	end

	return {
		diagnostics = {
			diagnostic,
		},
	}
end

return analyzeStorybook
