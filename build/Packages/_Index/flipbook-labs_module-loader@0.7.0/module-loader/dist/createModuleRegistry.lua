local types = require(script.Parent.types)

type LoadedModule = types.LoadedModule
type ModuleRegistry = types.ModuleRegistry

local function createModuleRegistry(): ModuleRegistry
	local registry = {
		byInstance = {},
		byPath = {},
	}

	local function add(moduleScript: ModuleScript, loadedModule: LoadedModule)
		registry.byInstance[moduleScript] = loadedModule
		registry.byPath[moduleScript:GetFullName()] = loadedModule
	end

	local function remove(moduleScript: ModuleScript)
		registry.byInstance[moduleScript] = nil
		registry.byPath[moduleScript:GetFullName()] = nil
	end

	local function getAllModules(): { ModuleScript }
		local modules = {}
		for moduleScript in registry.byInstance do
			table.insert(modules, moduleScript)
		end
		return modules
	end

	local function reset()
		table.clear(registry.byInstance)
		table.clear(registry.byPath)
	end

	local function getByInstance(moduleScript: ModuleScript): LoadedModule?
		return registry.byInstance[moduleScript]
	end

	local function getByFullName(fullName: string): LoadedModule?
		return registry.byPath[fullName]
	end

	return {
		add = add,
		remove = remove,
		reset = reset,
		getAllModules = getAllModules,
		getByInstance = getByInstance,
		getByFullName = getByFullName,
	}
end

return createModuleRegistry
