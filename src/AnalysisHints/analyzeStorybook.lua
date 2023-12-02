local flipbook = script:FindFirstAncestor("flipbook")

local types = require(flipbook.types)
local isStorybookModule = require(flipbook.Story.isStorybookModule)
local analysisHintsTypes = require(flipbook.AnalysisHints.types)
local getLineFromTypecheckError = require(flipbook.AnalysisHints.getLineFromTypecheckError)

type Storybook = types.Storybook
type ScriptAnalysisDiagnostic = analysisHintsTypes.ScriptAnalysisDiagnostic
type ScriptAnalysisResponse = analysisHintsTypes.ScriptAnalysisResponse

local function analyzeStorybook(module: ModuleScript, loader: any): ScriptAnalysisResponse
	local diagnostic: ScriptAnalysisDiagnostic?

	if isStorybookModule(module) then
		local storybook = loader:require(module)
		local success, message = types.Storybook(storybook)

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
