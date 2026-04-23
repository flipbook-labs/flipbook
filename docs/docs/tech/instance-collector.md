---
aliases: [Instance Collector]
linter-yaml-title-alias: Instance Collector
notion-id: 2db95b79-12f8-816a-acc3-f5fe333da4cc
---

# Instance Collector

## User Journeys to Consider

For each, remember to consider Rojo and Studio workflows. The former will have everything synced at once, the latter will be incremental changes (i.e. insert ModuleScript, rename, edit source)

1. Creating a new storybook
2. Creating a story for an existing storybook
3. Creating a new story when there are no storybooks
4. Changing a ModuleScript's Name or Source
    1. Could generalize this to any property change for simplicity
    2. At the least, if the Source is actively being edited then wait to recompute (I think there's an API to check if a source contrainer is being edited)

## New Idea

What I want is a way to…

5. Query the entire DataModel for a subset of Instances
    1. Class-based is fine, so QueryDescendants works well
6. Refresh based on specified properties changing
    2. Subscribe to the Name and Source of a ModuleScript changing, and trigger an update when they do
7. Instances added after the fact get picked up and funnel through the same flow
    3. Need to use DescendantAdded to handle incremental additions
    4. May to toss instances into a queue to periodically process batches
8. Matching Instances that get removed/destroyed are removed from the list of matches, triggers an update

I think what I ultimately want is a generic, powerful query system that allows me to remove most (if not all) of the `onFoo` functions from StorytellerStore

API ideating

```lua
-- StorytellerStore.luau

type InstanceCollection = {
	new: ({
		query: string,
		matcher: ((candidate: Instance) -> boolean)?,
		changes: { string }
	}) -> InstanceCollection,
	Get: (self: InstanceCollection) -> { Instance },
	Changed: RBXScriptSignal,
}

type QueryChanges = {
	
}

local storybookModules, setStorybookModules = Signals.createSignal({} :: { ModuleScript })


local storybookModulesQuery = createInstanceQuery({
	selector = "ModuleScript",
	matcher = isStorybookModule,
	watchedProperties = {
		"Name",
		"Source",
	},
	shouldUpdate = function(candidate: Instance, prevCandidate: Instance)
		if candidate.Source ~= prevCandidate.Source then
			return not ScriptEditorService:FindScriptDocument(candidate)
		end
		return true
	end
})

storybookModulesQuery.changed:Connect(function(changes)
	-- If there is only one changed instance, and the Source property was 
	--changed, AND there are no locks on the module, then do nothing
	
	setStorybookModules(storybookModulesCollection:Get())
end)
```

Another thought on how to handle updating based on complex changes:

```lua
--local ScriptEditorService = game:GetService("ScriptEditorService")

type QueryOptions = {
	selector: string,
	shouldUpdate: ((instance: Instance, changedProperty: string) -> boolean)?
}

type QueryResult = {
	get: () -> { Instance },
	changed: RBXScriptSignal,
}

local function query(options: QueryOptions): QueryResult
	local changed = Instance.new("BindableEvent")
	local matches = {}

	local function get()
		return matches
	end

	-- This is where the initial discovery will happen

	return {
		get = get,
		changed = changed.Event,
	}
end

local moduleScripts = query({
	selector = "ModuleScript",
	-- Instead of this, maybe I will just go the normal "changes" array like in
	-- the previous example. If it's not too expensive, it would simplify things
	-- to just listen for any ModuleScript changes, and then determine 
	-- afterwards if an update is needed
	shouldUpdate = function(instance, changedProperty)
		if changedProperty == "Source" then
			return not ScriptEditorService:FindScriptDocument(instance)
		end

		return true
	end,
})

print(moduleScripts.get())
moduleScripts.changed:Connect(print)

```
