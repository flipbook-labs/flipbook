local Storyteller = require("@pkg/Storyteller")

local booleanControl = Storyteller.createBooleanControl(false)
local selectControl = Storyteller.createSelectControl({ "Small", "Medium", "Large" }, {
	default = "Medium",
})

return {
	booleanControl = booleanControl,
	selectControl = selectControl,
}
