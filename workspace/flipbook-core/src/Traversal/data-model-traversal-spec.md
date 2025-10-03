# DataModel Traversal Spec

Input:

- `root: Instance`
- `predicate: (instance: Instance) -> boolean`

Output:

- `collection: { Instance }`

Requirements:

* Traversal is only done once
* Collections are updated when instance ancestry changes
  * DescendantAdded is used to add new instances to the queue for processing
  * AncestryChanged is used to remove instances from the collection
* Space efficiency is important
  * Keep the queue small
  * Avoid GetDescendants() like the plague
  * GetChildren() poses a bit of a concern if an instance has a massive
	number of children but I don't think there's a better alternative for traversal
* Time efficiency is less important
  * Prioritize memory consumption and minimizing FPS impact over
	time-to-complete. We do not want to be doing so much work that we overload
	the frame budget
* Handle instances being added/removed from the DataModel while traversal is ongoing
* Matches are made via a predicate
* If the instance to traverse is the DataModel, do some special ordering on the
  initial list of services to traverse.
  * Manually define the most common services to check first. After that, iterate
    through the rest in any order

We should consider[ ~1 million
instances](https://roblox.atlassian.net/wiki/spaces/MUS/pages/2885091984/Now+Playing+August+Tech+Sync)
to be the highest number we'll feasibly have to process for an experience. There
is technically no limit but this should be the upper bound for the vast majority
of experiences.

[React scheduler for reference](https://github.com/Roblox/roact-alignment/blob/main/modules/scheduler/src/forks/SchedulerHostConfig.default.lua)

```luau
local SERVICE_SEARCH_ORDER = {
	"ServerScriptService",
	"ServerStorage",
	"ReplicatedStorage",
	"ReplicatedFirst",
	"CoreGui",
	"CorePackages",
	"Workspace",
	"StarterGui",
	"StarterPlayer",
}
```

```luau
local getCollection = collectInstancesAsync(game, function(instance)
	return isStoryModule(instance) or isStorybookModule(instance)
end)

local collection = useSignalState(getCollection)

local groups = useMemo(function()
	local storyModules: { ModuleScript } = {}
	local storybookModules: { ModuleScript } = {}

	for _, instance in collection do
		if isStoryModule(instance) then
			table.insert(storyModules, instance)
		elseif isStorybookModule(instance) then
			table.insert(storybookModules, instance)
		end
	end

	return {
		storyModules = storyModules,
		storybookModules = storybookModules,
	}
end, { collection })
```

DataModelStore would be something we create in Flipbook on top of the instance
collection logic. All the collection processing will be handled behind the
scenes, then we'll have some nice functions on top to kick off the initial
collection and then get the results later

```luau
type DataModelStore = {
	collect: (root: Instance) -> (),
	getStoryModules: Signals.getter<{ ModuleScript }>,
	getStorybookModules: Signals.getter<{ ModuleScript }>,
}
```

Then in a component we can simply do...
```luau
local storyModules = useSignalState(DataModelStore.getStoryModules)
local storybookModules = useSignalState(DataModelStore.getStorybookModules)
```

And these will both trigger a state update when new instances are added/removed.

Note that `DataModelStore.collect` may be called around the same time that
`useSignalState` is called, which may mean Flipbook's sidebar (for example)
will be receiving several state updates before finally settling on the full
list of instances. This is probably fine, but we could also consider a way to
batch the updates in case there's a performance bottleneck


## Alternative approach with tagging

Continue to traverse the entire DataModel over time to ensure no harm to FPS,
but do this in the background. Any time a predicate is matched, apply a tag to
the instance.

CollectionService then becomes the source of truth for the collection, and we
can respond to InstanceAdded, InstanceRemoved, and use GetTagged for the initial
list.

We'd essentially have a quiet background task that just keeps the tags up to
date.
