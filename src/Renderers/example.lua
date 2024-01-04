render = function(target, props)
	local label = Instance.new("TextLabel")
	label.Text = if props.args.isEnabled then "Enabled" else "Disabled"

	return function()
		label:Destroy()
	end
end

-- Plain GuiObjects
exports.PrimaryRoblox = {
	args = {
		isEnabled = true,
	},
	renderer = RobloxRenderer,
	render = function(args)
		local label = Instance.new("TextLabel")
		label.Text = if args.isEnabled then "Enabled" else "Disabled"

		return label
	end,
}

-- Fusion
local function Button(props)
	local isHovering = Value(false)

	return New("TextButton")({
		BackgroundColor3 = Computed(function()
			return if isHovering:get() then HOVER_COLOUR else REST_COLOUR
		end),

		[OnEvent("MouseEnter")] = function()
			isHovering:set(true)
		end,

		[OnEvent("MouseLeave")] = function()
			isHovering:set(false)
		end,

		-- ... some properties ...
	})
end
exports.PrimaryFusion = {
	args = {
		isEnabled = true,
	},
	renderer = FusionRenderer,
	render = function(args)
		return new("TextLabel")({
			Text = if args.isEnabled then "Enabled" else "Disabled",
		})
	end,
}
