-- moving this file to LuaApps, please replicate any changes in the LuaApps file as well
local DetailsPage = script.Parent.Parent
local Template = DetailsPage.Parent
local App = Template.Parent
local UIBlox = App.Parent
local Packages = UIBlox.Parent
local enumerate = require(Packages.enumerate)

local UIBloxConfig = require(UIBlox.UIBloxConfig)

return if UIBloxConfig.moveDetailsPageToLuaApps
	then nil
	else enumerate("ContentPosition", {
		"Left",
		"Right",
	})
