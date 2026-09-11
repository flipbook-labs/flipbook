local CoreGui = game:GetService("CoreGui")

local Foundation = require("@rbxpkg/Foundation")
local JestGlobals = require("@pkg/JestGlobals")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local Group = require("./Group")
local Panel = require("./Panel")
local Root = require("./Root")

local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach
local describe = JestGlobals.describe
local expect = JestGlobals.expect
local test = JestGlobals.test

local act = ReactRoblox.act

local function ContextProviders(props: { children: React.Node })
	return React.createElement(Foundation.FoundationProvider, {
		theme = "Dark" :: "Dark",
	}, props.children)
end

local container
local root

beforeEach(function()
	container = Instance.new("Folder")
	container.Parent = CoreGui

	root = ReactRoblox.createRoot(container)
end)

afterEach(function()
	container:Destroy()
end)

test("Root should always take up the full container", function()
	local element = React.createElement(ContextProviders, nil, {
		Wrapper = React.createElement(Foundation.View, {
			Size = UDim2.fromOffset(800, 800),
		}, {
			PanelLayout = React.createElement(Root, nil, {}),
		}),
	})

	act(function()
		root:render(element)
	end)

	local panelLayout = container:QueryDescendants("#PanelLayout")[1] :: GuiObject
	expect(panelLayout.AbsoluteSize).toEqual(Vector2.new(800, 800))
end)

describe("layouting", function()
	test("panels should be rendered horizontally by default", function()
		local element = React.createElement(ContextProviders, nil, {

			PanelLayout = React.createElement(Root, nil, {
				PrimarySidebar = React.createElement(Panel, {
					id = "primary-sidebar",
					defaultSize = 200,
				}),

				Content = React.createElement(Panel, {
					id = "content",
					defaultSize = 500,
				}),

				SecondarySidebar = React.createElement(Panel, {
					id = "secondary-sidebar",
					defaultSize = 300,
				}),
			}),
		})

		act(function()
			root:render(element)
		end)

		local primarySidebar = container:QueryDescendants("#PrimarySidebar")[1] :: GuiObject
		local content = container:QueryDescendants("#Content")[1] :: GuiObject
		local secondarySidebar = container:QueryDescendants("#SecondarySidebar")[1] :: GuiObject

		expect(primarySidebar.AbsolutePosition.X).toEqual(0)
		expect(content.AbsolutePosition.X).toBeGreaterThan(primarySidebar.AbsolutePosition.X)
		expect(secondarySidebar.AbsolutePosition.X).toBeGreaterThan(content.AbsolutePosition.X)
	end)

	test("panels in a group should be rendered vertically by default", function()
		local element = React.createElement(ContextProviders, nil, {
			PanelLayout = React.createElement(Root, nil, {
				Group = React.createElement(Group, {
					id = "group",
				}, {
					FirstPanel = React.createElement(Panel, {
						id = "first-panel",
						defaultSize = 400,
					}),

					SecondPanel = React.createElement(Panel, {
						id = "second-panel",
						defaultSize = 200,
					}),
				}),
			}),
		})

		act(function()
			root:render(element)
		end)

		local firstPanel = container:QueryDescendants("#FirstPanel")[1] :: GuiObject
		local secondPanel = container:QueryDescendants("#SecondPanel")[1] :: GuiObject

		expect(firstPanel.AbsolutePosition).toEqual(Vector2.new(0, 0))
		expect(firstPanel.AbsoluteSize.Y).toEqual(400)

		expect(firstPanel.AbsoluteSize.Y).toBeGreaterThan(0)
		expect(secondPanel.AbsoluteSize.Y).toBeGreaterThan(firstPanel.AbsoluteSize.Y)
	end)
end)
