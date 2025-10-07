local Sift = require(script.Parent.Parent.Parent.Sift)

local types = require(script.Parent.Parent.types)

type LoadedStory<T> = types.LoadedStory<T>
type StoryProps = types.StoryProps
type StoryRenderer<T> = types.StoryRenderer<T>

type Packages = {
	Fusion: any,
}

local function createFusionRenderer(packages: Packages): StoryRenderer<Instance>
	local Fusion = packages.Fusion

	local handle: Instance?
	local scope

	local function mount(container: Instance, story: LoadedStory<Instance>, props: StoryProps)
		if typeof(story.story) == "Instance" then
			handle = story.story
		elseif typeof(story.story) == "function" then
			handle = story.story(props)
		end

		if handle then
			handle.Parent = container
		end
	end

	local function unmount()
		if handle then
			handle:Destroy()
		end
		if scope then
			scope:doCleanup()
		end
	end

	local function update(props: StoryProps, prevProps: StoryProps?)
		-- Fusion needs to retain its Instance identity. Instead of remounting,
		-- we leave `handle` alone and mutate the controls with the newly
		-- updated values
		if props.controls and prevProps and prevProps.controls then
			for key, arg in props.controls do
				local prevControl = prevProps.controls[key]

				if prevControl then
					prevControl:set(arg)
				end
			end
		end

		return nil
	end

	local function shouldUpdate(_props: StoryProps, prevProps: StoryProps?)
		-- Arg changes should never trigger a remount. We retain the Value
		-- identities to Fusion can handle its update logic
		if prevProps then
			return false
		end
		return true
	end

	local function transformProps(props: StoryProps, prevProps: StoryProps?)
		if props.controls then
			local transformed = table.clone(props)

			if not scope and rawget(Fusion, "scoped") then
				-- Fusion V3
				scope = Fusion:scoped()
			end

			transformed.controls = Sift.Dictionary.map(props.controls, function(arg, key)
				local prevControl = if prevProps and prevProps.controls then prevProps.controls[key] else nil

				if prevControl then
					return prevControl
				else
					return if scope then scope:Value(arg) else Fusion.Value(arg)
				end
			end)

			return transformed
		else
			return props
		end
	end

	return {
		mount = mount,
		unmount = unmount,
		update = update,
		shouldUpdate = shouldUpdate,
		transformProps = transformProps,
	}
end

return createFusionRenderer
