return function()
	local flipbook = script:FindFirstAncestor("flipbook")

	local Fusion = require(flipbook.Packages.Fusion)
	local createFusionRenderer = require(script.Parent.createFusionRenderer)

	local New = Fusion.New
	local Value = Fusion.Value
	type StateObject<T> = Fusion.StateObject<T>

	type ButtonProps = {
		isDisabled: StateObject<boolean>,
	}
	local function Button(props)
		return New("TextButton")({
			Text = if props.isDisabled:get() then "Disabled" else "Enabled",
		})
	end

	it("should render a Fusion component", function()
		local renderer = createFusionRenderer({ Fusion = Fusion })
		local args = {
			isDisabled = Value(false),
		}

		local target = Instance.new("Folder")
		local gui = renderer.mount(target, Button, args)

		expect(gui).to.be.ok()
		expect(gui.Text).to.equal("Enabled")
	end)

	it("should unmount a Fusion component", function()
		local renderer = createFusionRenderer({ Fusion = Fusion })
		local args = {
			isDisabled = Value(false),
		}

		local target = Instance.new("Folder")
		local gui = renderer.mount(target, Button, args)

		expect(gui).to.be.ok()
		expect(gui:IsDescendantOf(game)).to.equal(true)

		renderer.unmount()

		expect(gui:IsDescendantOf(game)).to.equal(false)
	end)

	it("should update the component on arg changes", function()
		local renderer = createFusionRenderer({ Fusion = Fusion })
		local args = {
			isDisabled = Value(false),
		}

		local target = Instance.new("Folder")
		local gui = renderer.mount(target, Button, args)

		expect(gui).to.be.ok()
		expect(gui:IsDescendantOf(game)).to.equal(true)

		renderer.unmount()

		expect(gui:IsDescendantOf(game)).to.equal(false)
	end)

	it("should never re-mount on arg changes", function() end)
end
