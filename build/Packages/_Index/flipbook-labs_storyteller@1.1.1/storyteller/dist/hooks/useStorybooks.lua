local ModuleLoader = require(script.Parent.Parent.Parent.ModuleLoader)
local React = require(script.Parent.Parent.Parent.React)

local findStorybookModules = require(script.Parent.Parent.findStorybookModules)
local isStorybookModule = require(script.Parent.Parent.isStorybookModule)
local loadStorybookModule = require(script.Parent.Parent.loadStorybookModule)
local types = require(script.Parent.Parent.types)

local useCallback = React.useCallback
local useEffect = React.useEffect
local useRef = React.useRef
local useState = React.useState
local useMemo = React.useMemo

type ModuleLoader = ModuleLoader.ModuleLoader
type LoadedStorybook = types.LoadedStorybook
type UnavailableStorybook = types.UnavailableStorybook

--[=[
	Performs all the discovery and loading of Storybook modules that would
	normally be done via individual API members.

	This hook makes it possible to conveniently load (and reload) Storybooks for
	use in React UI.

	:::info
	In the future version hooks may be migrated to a new package to remove the React dependency from Storyteller.
	:::

	Usage:

	```lua
	local React = require("@pkg/React")
	local Storyteller = require("@pkg/Storyteller")

	local e = React.createElement

	local function StorybookList(props: {
		parent: Instance,
	})
		local storybooks = Storyteller.useStorybooks(props.parent)

		local children = {}
		for index, storybook in storybooks do
			children[storybook.name] = e("TextLabel", {
				Text = storybook.name,
				LayoutOrder = index,
			}),
		end

		return e("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}, {
			Layout = e("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
		}, children)
	end

	return StorybookList
	```

	This hook triggers a rerender when a Storybook module changes. For example,
	updating the `storyRoots` of a Storybook will trigger a rerender, and when
	paired with `useStory` you can get live updates to which Stories a Storybook
	manages.

	@tag React
	@tag Storybook
	@within Storyteller
]=]
local function useStorybooks(parent: Instance): {
	available: { LoadedStorybook },
	unavailable: { UnavailableStorybook },
}
	local storybookConnections = useRef({} :: { [ModuleScript]: { RBXScriptConnection } })
	local storybooks, setStorybooks = useState({} :: { [ModuleScript]: LoadedStorybook | UnavailableStorybook })

	local getOrCreateConnectionObject = useCallback(function(storybookModule: ModuleScript): { RBXScriptConnection }
		local existing = storybookConnections.current[storybookModule]
		if existing then
			return existing
		else
			local new = {}
			storybookConnections.current[storybookModule] = new
			return new
		end
	end, {})

	local loadStorybook = useCallback(function(storybookModule: ModuleScript)
		local connections = getOrCreateConnectionObject(storybookModule)
		local loader = ModuleLoader.new()

		local reloadStorybook

		local function load()
			local storybook: LoadedStorybook?
			local success, result = pcall(function()
				storybook = loadStorybookModule(storybookModule, loader)
			end)

			table.insert(connections, loader.loadedModuleChanged:Connect(reloadStorybook))
			table.insert(connections, storybookModule.AncestryChanged:Connect(reloadStorybook))

			setStorybooks(function(prev)
				local new = table.clone(prev)

				if success and storybook then
					new[storybookModule] = storybook
				else
					local unavailableStorybook: UnavailableStorybook = {
						problem = result,
						storybook = {
							name = storybookModule.Name,
							loader = loader,
							source = storybookModule,
							storyRoots = {},
						},
					}
					new[storybookModule] = unavailableStorybook
				end

				return new
			end)
		end

		function reloadStorybook(instance: Instance)
			if instance == storybookModule then
				if instance.Parent ~= nil and isStorybookModule(instance) then
					for _, connection in connections do
						connection:Disconnect()
					end

					loader:clear()
					load()
				else
					setStorybooks(function(prev)
						local new = table.clone(prev)
						new[storybookModule] = nil
						return new
					end)
				end
			end
		end

		load()
	end, {})

	useEffect(function()
		setStorybooks({})

		local storybookModules = findStorybookModules(parent)

		for _, storybookModule in storybookModules do
			task.spawn(loadStorybook, storybookModule)
		end

		local conn = parent.DescendantAdded:Connect(function(descendant)
			if isStorybookModule(descendant) then
				loadStorybook(descendant :: ModuleScript)
			end
		end)

		return function()
			conn:Disconnect()

			for _, connections in storybookConnections.current do
				for _, connection in connections do
					connection:Disconnect()
				end
			end
		end
	end, { parent } :: { unknown })

	return useMemo(function()
		local available: { LoadedStorybook } = {}
		local unavailable: { UnavailableStorybook } = {}

		for _, storybook in storybooks do
			if storybook["problem"] == nil then
				table.insert(available, (storybook :: any) :: LoadedStorybook)
			else
				table.insert(unavailable, (storybook :: any) :: UnavailableStorybook)
			end
		end

		return {
			available = available,
			unavailable = unavailable,
		}
	end, { storybooks })
end

return useStorybooks
