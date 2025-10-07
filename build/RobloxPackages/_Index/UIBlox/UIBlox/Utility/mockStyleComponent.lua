local Component = script.Parent
local UIBlox = Component.Parent
local Roact = require(UIBlox.Parent.Roact)

local AppStyleProvider = require(UIBlox.App.Style.AppStyleProvider)
local FoundationProvider = require(UIBlox.Parent.Foundation).FoundationProvider

local StyleTypes = require(UIBlox.App.Style.StyleTypes)
type Settings = StyleTypes.Settings

return function(elements, settings: Settings?)
	return Roact.createElement(
		FoundationProvider,
		{
			theme = "Dark",
			preferences = if settings
				then {
					reducedMotion = settings.reducedMotion,
					preferredTransparency = settings.preferredTransparency,
				}
				else nil,
		},
		Roact.createElement(AppStyleProvider, {
			style = {
				themeName = "Dark",
				fontName = "Gotham",
				settings = settings,
			},
		}, {
			Content = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
			}, elements),
		})
	)
end
