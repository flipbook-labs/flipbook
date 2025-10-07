--[[
	validateShoes.lua performs any checks that requires checking an asset against another asset in the shoes bundle
]]

local root = script.Parent.Parent

local Types = require(root.util.Types)

local function validateShoes(_validationContext: Types.ValidationContext): (boolean, { string }?)
	return true -- this is a placeholder function for the moment
end

return validateShoes
