export type LoadingStrategy = "Automatic" | "LoadString" | "LoadModule"

export type LoadedModuleExports = unknown?

export type LoadedModule = {
	instance: ModuleScript,
	isLoaded: boolean,
	exports: LoadedModuleExports,
	dependencies: { [ModuleScript]: boolean },
	consumers: { [ModuleScript]: boolean },
}

export type ModuleRegistry = {
	add: (moduleScript: ModuleScript, loadedModule: LoadedModule) -> (),
	remove: (moduleScript: ModuleScript) -> (),
	reset: () -> (),
	getAllModules: () -> { ModuleScript },
	getByInstance: (moduleScript: ModuleScript) -> LoadedModule?,
	getByFullName: (fullName: string) -> LoadedModule?,
}

export type LoadModuleFn = (moduleScript: ModuleScript) -> LoadedModuleExports

export type ModuleLoader = {
	_getModuleRegistry: () -> ModuleRegistry,

	require: LoadModuleFn,
	loadModule: LoadModuleFn,
	cache: (moduleScript: ModuleScript, result: LoadedModuleExports) -> (),
	clearModule: (moduleScript: ModuleScript) -> (),
	clear: () -> (),

	setLoadingStrategy: (loadingStrategy: LoadingStrategy) -> (),

	loadedModuleChanged: RBXScriptSignal,
}

return nil
