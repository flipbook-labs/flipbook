return function()
	local React = require("@pkg/React")
	local ReactRoblox = require("@pkg/ReactRoblox")
	local useEvent = require("@root/Common/useEvent")
	local usePrevious = require("./usePrevious")

	local container = Instance.new("ScreenGui")
	local root = ReactRoblox.createRoot(container)

	local toggleState = Instance.new("BindableEvent")

	local function HookTester()
		local state, setState = React.useState(false)
		local prev = usePrevious(state)

		useEvent(toggleState.Event, function()
			setState(not state)
		end)

		return React.createElement("TextLabel", {
			Text = tostring(prev),
		})
	end

	afterEach(function()
		ReactRoblox.act(function()
			root:unmount()
		end)
	end)

	it("should use the last value", function()
		local element = React.createElement(HookTester)

		ReactRoblox.act(function()
			root:render(element)
		end)

		local result = container:FindFirstChildWhichIsA("TextLabel") :: TextLabel

		expect(result.Text).to.equal("nil")

		ReactRoblox.act(function()
			toggleState:Fire()
		end)

		ReactRoblox.act(function()
			task.wait()
		end)

		expect(result.Text).to.equal("false")

		ReactRoblox.act(function()
			toggleState:Fire()
		end)

		ReactRoblox.act(function()
			task.wait()
		end)

		expect(result.Text).to.equal("true")
	end)
end
