local React = require("@pkg/React")

local useEffect = React.useEffect

-- Specs read and call props whose types differ for each component.
-- lute-lint-ignore(no_any)
type Props = { [string]: any }

export type FoundationStub = {
	components: { [string]: unknown },
	getMountedProps: (componentName: string) -> { Props },
}

--[[
	Specs run on a cloud server with no mouse, so they can't press Foundation's
	buttons or checkboxes. Foundation's Dialog errors there too, because its
	animation connects to RenderStepped. A spec can mock Foundation with
	`components` instead.

	Each stubbed component renders only its children. `getMountedProps` returns
	the props of every mounted copy of a component, so a spec can read them and
	call their callbacks. Its argument is the component's name, such as
	"Checkbox" or "Dialog.Root".

	`components` only has the parts of Foundation that the components under test
	use.
]]
local function createFoundationStub(): FoundationStub
	local mountedProps: { [string]: { Props } } = {}

	local function getMountedProps(componentName: string): { Props }
		return mountedProps[componentName] or {}
	end

	local function createComponent(componentName: string)
		return function(props: Props): React.Node
			useEffect(function()
				local mounted = getMountedProps(componentName)
				mountedProps[componentName] = mounted
				table.insert(mounted, props)

				return function()
					local index = table.find(mounted, props)
					if index then
						table.remove(mounted, index)
					end
				end
			end, { props })

			return React.createElement(React.Fragment, nil, props.children)
		end
	end

	return {
		components = {
			Checkbox = createComponent("Checkbox"),
			Dialog = {
				Actions = createComponent("Dialog.Actions"),
				Content = createComponent("Dialog.Content"),
				Root = createComponent("Dialog.Root"),
				Text = createComponent("Dialog.Text"),
				Title = createComponent("Dialog.Title"),
			},
			Enums = {
				ButtonVariant = {
					Emphasis = "Emphasis",
				},
			},
			View = createComponent("View"),
		},
		getMountedProps = getMountedProps,
	}
end

return createFoundationStub
