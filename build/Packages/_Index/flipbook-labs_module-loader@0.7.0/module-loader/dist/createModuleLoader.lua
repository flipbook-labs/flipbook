local Janitor = require(script.Parent.Parent.Janitor)
local LuauPolyfill = require(script.Parent.Parent.LuauPolyfill)

local cleanLoadstringStack = require(script.Parent.cleanLoadstringStack)
local createModuleRegistry = require(script.Parent.createModuleRegistry)
local getCallerPath = require(script.Parent.getCallerPath)
local getModuleSource = require(script.Parent.getModuleSource)
local getRobloxTsRuntime = require(script.Parent.getRobloxTsRuntime)
local types = require(script.Parent.types)

local Error = LuauPolyfill.Error

type LoadedModule = types.LoadedModule
type LoadedModuleExports = types.LoadedModuleExports
type LoadingStrategy = types.LoadingStrategy
type LoadModuleFn = types.LoadModuleFn
type ModuleLoader = types.ModuleLoader
type ModuleRegistry = types.ModuleRegistry

local loadmodule: (ModuleScript) -> (() -> LoadedModuleExports, string?, () -> ()) = debug["loadmodule"]
local loadModuleEnabled = pcall(function()
	return loadmodule(Instance.new("ModuleScript"))
end)

--[=[
	ModuleScript loader that bypasses Roblox's require cache.

	This class aims to solve a common problem where code needs to be run in
	Studio, but once a change is made to an already required module the whole
	place must be reloaded for the cache to be reset. With this class, the cache
	is ignored when requiring a module so you are able to load a module, make
	changes, and load it again without reloading the whole place.

	@class ModuleLoader
]=]
function createModuleLoader(): ModuleLoader
	local moduleRegistry = createModuleRegistry()
	local loadedModuleFns: { [ModuleScript]: { any } } = {}
	local cleanupFns: { () -> () } = {}
	local loadingStrategy: LoadingStrategy = "Automatic"
	local janitors: { [ModuleScript]: any } = {}

	local function _getModuleRegistry()
		return moduleRegistry
	end

	local function setLoadingStrategy(strategy: LoadingStrategy)
		loadingStrategy = strategy
	end

	--[=[
		Fired when any ModuleScript required through this class has its ancestry
		or `Source` property changed. This applies to the ModuleScript passed to
		`ModuleLoader:require()` and every module that it subsequently requirs.

		This event is useful for reloading a module when it or any of it
		dependencies change.

		```lua
		local loader = createModuleLoader()
		local result = loader.require(module)

		loader.loadedModuleChanged:Connect(function()
			loader.clear()
			result = loader.require(module)
		end)
		```

		@prop loadedModuleChanged RBXScriptSignal
		@within ModuleLoader
	]=]
	local loadedModuleChanged = Instance.new("BindableEvent")

	local loadModule: LoadModuleFn

	local function getConsumers(moduleScript: ModuleScript): { ModuleScript }
		local function getConsumersRecursively(loadedModule: LoadedModule, found: { [ModuleScript]: true })
			for consumer in loadedModule.consumers do
				local loadedChildModule = moduleRegistry.getByInstance(consumer)

				if loadedChildModule then
					if not found[loadedChildModule.instance] then
						found[loadedChildModule.instance] = true
						getConsumersRecursively(loadedChildModule, found)
					end
				end
			end
		end

		local loadedModule: LoadedModule? = moduleRegistry.getByInstance(moduleScript)

		if loadedModule then
			local found = {}

			getConsumersRecursively(loadedModule, found)

			local consumers = {}
			for consumer in found do
				table.insert(consumers, consumer)
			end

			return consumers
		else
			return {}
		end
	end

	local function clearModule(moduleToClear: ModuleScript)
		if not moduleRegistry.getByInstance(moduleToClear) then
			return
		end

		local consumers = getConsumers(moduleToClear)
		local modulesToClear = { moduleToClear, table.unpack(consumers) }

		local index = table.find(modulesToClear, getRobloxTsRuntime())
		if index then
			table.remove(modulesToClear, index)
		end

		for _, moduleScript in modulesToClear do
			local loadedModule = moduleRegistry.getByInstance(moduleScript)

			if loadedModule then
				local janitor = janitors[moduleScript]
				janitor:Cleanup()
			end
		end

		for _, moduleScript in modulesToClear do
			loadedModuleChanged:Fire(moduleScript)
		end
	end

	--[=[
		Tracks the changes to a required module's ancestry and `Source`.

		When ancestry or `Source` changes, the `loadedModuleChanged` event is fired.
		When this happens, the user should clear the cache and require the root
		module again to reload.

		@private
	]=]
	local function trackChanges(moduleScript: ModuleScript)
		local existingJanitor = janitors[moduleScript]
		local janitor = if existingJanitor then existingJanitor else Janitor.new()

		janitor:Cleanup()

		janitor:Add(moduleScript.AncestryChanged:Connect(function()
			clearModule(moduleScript)
		end))

		janitor:Add(moduleScript.Changed:Connect(function(prop: string)
			if prop == "Source" then
				clearModule(moduleScript)
			end
		end))

		janitor:Add(function()
			moduleRegistry.remove(moduleScript)
			loadedModuleFns[moduleScript] = nil
		end)

		janitors[moduleScript] = janitor
	end

	--[=[
		Set the cached value for a module before it is loaded.

		This is useful is very specific situations. For example, this method is
		used to cache a copy of Roact so that when a module is loaded with this
		class it uses the same table instance.

		```lua
		local moduleInstance = script.Parent.ModuleScript
		local moduleScript = require(moduleInstance)

		local loader = createModuleLoader()
		loader.cache(moduleInstance, moduleScript)
		```
	]=]
	local function cache(moduleScript: ModuleScript, result: any)
		local loadedModule: LoadedModule = {
			instance = moduleScript,
			exports = result,
			isLoaded = true,
			dependencies = {},
			consumers = {},
		}

		moduleRegistry.add(moduleScript, loadedModule)
	end

	local function execModule(loadedModule: LoadedModule)
		-- This method is adapted from:
		-- https://github.com/Roblox/jest-roblox/blob/408eac/src/jest-runtime/src/init.lua#L1847-L2102

		local moduleFunction, defaultEnvironment, errorMessage, cleanupFn
		local moduleScript = loadedModule.instance

		local shouldUseLoadmodule = loadingStrategy == "LoadModule"
			or (loadingStrategy == "Automatic" and loadModuleEnabled)

		local existingLoadedModuleFns = loadedModuleFns[moduleScript]
		if existingLoadedModuleFns then
			moduleFunction = existingLoadedModuleFns[1]
			defaultEnvironment = existingLoadedModuleFns[2]
		else
			if shouldUseLoadmodule then
				moduleFunction, errorMessage, cleanupFn = loadmodule(moduleScript)
			else
				moduleFunction, errorMessage = loadstring(getModuleSource(moduleScript), moduleScript:GetFullName())

				if errorMessage then
					errorMessage = cleanLoadstringStack(errorMessage)
				end
			end

			if not moduleFunction then
				error(Error.new(errorMessage))
			end

			-- Cache initial environment table to inherit from later
			defaultEnvironment = getfenv(moduleFunction)

			if loadedModuleFns then
				loadedModuleFns[moduleScript] = { moduleFunction, defaultEnvironment, cleanupFn }
			else
				if cleanupFn ~= nil then
					table.insert(cleanupFns, cleanupFn)
				end
			end
		end

		-- The default behavior for function environments is to inherit the table
		-- instance from the parent environment. This means that each invocation of
		-- `moduleFunction()` will return a new module instance but with the same
		-- environment table as `moduleFunction` loadModule the time of invocation.
		-- In order to properly sanbox module instances, we need to ensure that each
		-- instance has its own distinct environment table containing the specific
		-- overrides for it, but still inherits from the default parent environment
		-- for non-overriden environment goodies.

		-- This is the 'least mocked' environment that scripts will be able to see.
		-- The final function environment inherits from this sandbox. This is
		-- separate so that, in the future, `globalEnv` could expose these
		-- 'unmocked' functions instead of the ones in the global environment.
		local sandboxEnvironment = setmetatable({
			script = if shouldUseLoadmodule then defaultEnvironment.script else moduleScript,
			game = defaultEnvironment.game,
			workspace = defaultEnvironment.workspace,
			plugin = defaultEnvironment.plugin,

			-- legacy aliases for data model
			Game = defaultEnvironment.game,
			Workspace = defaultEnvironment.workspace,

			require = function(otherModule: ModuleScript | string)
				if typeof(otherModule) == "string" then
					-- Disabling this at the surface level of the API until we have
					-- deeper support in Jest.
					error("Require-by-string is not enabled for use inside Jest at this time.")
				end

				loadedModule.dependencies[otherModule] = true

				return loadModule(otherModule)
			end,
		}, {
			__index = defaultEnvironment,
		})

		-- This is the environment actually passed to scripts, including all global
		-- mocks and other customisations the user might choose to apply.
		local mockedSandboxEnvironment = setmetatable({}, {
			__index = sandboxEnvironment,
		})

		setfenv(moduleFunction, mockedSandboxEnvironment :: any)
		local moduleResult = table.pack(moduleFunction())

		if moduleResult.n ~= 1 then
			error(
				string.format(
'[Module Error]: %s did not return a valid result\n\tModuleScripts must return exactly one value'
,
					tostring(moduleScript)
				)
			)
		end

		trackChanges(moduleScript)

		loadedModule.exports = moduleResult[1]
	end

	--[=[
		Require a module with a fresh ModuleScript require cache.

		This method is functionally the same as running `require(script.Parent.ModuleScript)`,
		however in this case the module is not cached. As such, if a change occurs
		to the module you can call this method again to get the latest changes.

		```lua
		local loader = createModuleLoader()
		local module = loader.require(script.Parent.ModuleScript)
		```
	]=]
	function loadModule(moduleScript: ModuleScript)
		if moduleScript.Name:find(".global$") then
			return (require :: any)(moduleScript)
		end

		local caller: ModuleScript?
		local callerPath = getCallerPath()
		if callerPath then
			local loadedCallerModule = moduleRegistry.getByFullName(callerPath)
			if loadedCallerModule and loadedCallerModule.instance then
				caller = loadedCallerModule.instance
			end
		end

		local existingModule = moduleRegistry.getByInstance(moduleScript)
		if existingModule then
			if caller then
				existingModule.consumers[caller] = true
			end

			return existingModule.exports
		end

		-- We must register the pre-allocated module object first so that any
		-- circular dependencies that may arise while evaluating the module can
		-- be satisfied.
		local loadedModule: LoadedModule = {
			instance = moduleScript,
			exports = nil,
			isLoaded = false,
			dependencies = {},
			consumers = if caller
				then {
					[caller] = true,
				}
				else {},
		}

		moduleRegistry.add(moduleScript, loadedModule)

		local success, result = pcall(function()
			execModule(loadedModule)
			loadedModule.isLoaded = true
		end)
		if not success then
			moduleRegistry.remove(moduleScript)
			error(result)
		end

		return loadedModule.exports
	end

	--[=[
		Clears out the internal cache.

		While this module bypasses Roblox's ModuleScript cache, one is still
		maintained internally so that repeated requires to the same module return a
		cached value.

		This method should be called when you need to require a module again. i.e.
		if the module's Source has been changed.

		```lua
		local loader = createModuleLoader()
		loader.require(script.Parent.ModuleScript)

		-- Later...

		-- Clear the cache and require the module again
		loader.clear()
		loader.require(script.Parent.ModuleScript)
		```
	]=]
	local function clear()
		for _, janitor in janitors do
			janitor:Cleanup()
		end

		for _, cleanupFn in cleanupFns do
			cleanupFn()
		end

		moduleRegistry.reset()
		loadedModuleFns = {}
		cleanupFns = {}
		janitors = {}
	end

	return {
		_getModuleRegistry = _getModuleRegistry,

		cache = cache,
		loadModule = loadModule,
		require = loadModule,
		clearModule = clearModule,
		clear = clear,
		setLoadingStrategy = setLoadingStrategy,

		loadedModuleChanged = loadedModuleChanged.Event,
	}
end

return createModuleLoader
