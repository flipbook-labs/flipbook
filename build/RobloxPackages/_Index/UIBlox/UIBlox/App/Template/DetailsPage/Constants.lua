-- deprecating this file as part of the move to LuaApps, should no longer be in use
local DetailsPage = script.Parent
local Template = DetailsPage.Parent
local App = Template.Parent

local UIBlox = App.Parent
local UIBloxConfig = require(UIBlox.UIBloxConfig)

return if UIBloxConfig.moveDetailsPageToLuaApps
	then nil
	else {
		--Height of the background bar
		HeaderBarBackgroundHeight = {
			Desktop = 80,
			Mobile = 24,
		},

		SideMargin = {
			Desktop = 48,
			Mobile = 24,
		},
	}
