local createModuleLoader = require(script.Parent.createModuleLoader)
local types = require(script.Parent.types)

type ModuleLoader = types.ModuleLoader

type ModuleLoaderProps = {
	_loader: ModuleLoader,
	loadedModuleChanged: RBXScriptSignal,
}

type ModuleLoaderImpl = {
	__index: ModuleLoaderImpl,

	new: () -> ModuleLoaderClass,

	require: (self: ModuleLoaderClass, moduleScript: ModuleScript) -> any,
	cache: (self: ModuleLoaderClass, moduleScript: ModuleScript, result: any) -> (),
	clearModule: (self: ModuleLoaderClass, moduleScript: ModuleScript) -> (),
	clear: (self: ModuleLoaderClass) -> (),
}

export type ModuleLoaderClass = typeof(setmetatable({} :: ModuleLoaderProps, {} :: ModuleLoaderImpl))

--[=[
	ModuleScript loader that bypasses Roblox's require cache.

	This class aims to solve a common problem where code needs to be run in
	Studio, but once a change is made to an already required module the whole
	place must be reloaded for the cache to be reset. With this class, the cache
	is ignored when requiring a module so you are able to load a module, make
	changes, and load it again without reloading the whole place.

	@class ModuleLoader
]=]
local ModuleLoader = {} :: ModuleLoaderImpl
ModuleLoader.__index = ModuleLoader

--[=[
    Constructs a new ModuleLoader instance.
]=]
function ModuleLoader.new()
	local self = {}

	self._loader = createModuleLoader()

	--[=[
		Fired when any ModuleScript required through this class has its ancestry
		or `Source` property changed. This applies to the ModuleScript passed to
		`ModuleLoader:require()` and every module that it subsequently requirs.

		This event is useful for reloading a module when it or any of it
		dependencies change.

		```lua
		local loader = ModuleLoader.new()
		local result = loader:require(module)

		loader.loadedModuleChanged:Connect(function()
			loader:clear()
			result = loader:require(module)
		end)
		```

		@prop loadedModuleChanged RBXScriptSignal
		@within ModuleLoader
	]=]
	self.loadedModuleChanged = self._loader.loadedModuleChanged

	return setmetatable(self, ModuleLoader)
end

--[=[
	Set the cached value for a module before it is loaded.

	This is useful is very specific situations. For example, this method is
	used to cache a copy of Roact so that when a module is loaded with this
	class it uses the same table instance.

	```lua
	local moduleInstance = script.Parent.ModuleScript
	local moduleScript = require(moduleInstance)

	local loader = ModuleLoader.new()
	loader:cache(moduleInstance, moduleScript)
	```
]=]
function ModuleLoader:cache(moduleScript: ModuleScript, result: any)
	self._loader.cache(moduleScript, result)
end

--[=[
	Require a module with a fresh ModuleScript require cache.

	This method is functionally the same as running `require(script.Parent.ModuleScript)`,
	however in this case the module is not cached. As such, if a change occurs
	to the module you can call this method again to get the latest changes.

	```lua
	local loader = ModuleLoader.new()
	local module = loader:require(script.Parent.ModuleScript)
	```
]=]
function ModuleLoader:require(moduleScript: ModuleScript)
	return self._loader.require(moduleScript)
end

function ModuleLoader:clearModule(moduleToClear: ModuleScript)
	self._loader.clearModule(moduleToClear)
end

--[=[
	Clears out the internal cache.

	While this module bypasses Roblox's ModuleScript cache, one is still
	maintained internally so that repeated requires to the same module return a
	cached value.

	This method should be called when you need to require a module again. i.e.
	if the module's Source has been changed.

	```lua
	local loader = ModuleLoader.new()
	loader:require(script.Parent.ModuleScript)

	-- Later...

	-- Clear the cache and require the module again
	loader:clear()
	loader:require(script.Parent.ModuleScript)
	```
]=]
function ModuleLoader:clear()
	self._loader.clear()
end

return ModuleLoader
