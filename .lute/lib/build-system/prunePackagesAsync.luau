local fs = require("@std/fs")
local path = require("@std/path")

local getDescendants = require("@scripts/lib/getDescendants")

--[[
	Wally and Rotriever each install into one folder, `Packages` and
	`RobloxPackages`. This module calls those the install folders. Every
	package gets its own folder inside an install folder's `_Index`, such as
	`Packages/_Index/jsdotlua_react@17.2.1`.

	Code doesn't require a package from `_Index` directly. It requires a
	linker: a small module that requires the package and returns it. The top
	of an install folder has a linker for each dependency the project
	declares, such as `Packages/React.lua`. Each package's folder in `_Index`
	holds the package's code in a subfolder, and beside that subfolder a
	linker for each of the package's own dependencies.
]]

export type Options = {
	-- The built plugin, with the install folders directly inside it.
	buildFolder: path.Pathlike,
	-- The names of the install folders, such as `Packages`.
	installFolderNames: { string },
}

-- Maps each linker's name, such as `React`, to its file.
type Linkers = { [string]: path.Path }

local INDEX_NAME = "_Index"

--[[
	Some of a package's files never load as part of the plugin. Scripts aren't
	modules, so nothing can require them, and nothing in the plugin requires a
	package's tests or benchmarks. A package that only these files require
	doesn't count as reached.
]]
local DEVELOPMENT_FILE_PATTERNS = {
	"%.server%.luau?$",
	"%.client%.luau?$",
	"%.spec%.luau?$",
	"%.test%.luau?$",
	"%.bench%.luau?$",
}

local function isLuauFile(filePath: path.Pathlike): boolean
	local extension = path.extname(filePath)
	return extension == ".lua" or extension == ".luau"
end

local function isDevelopmentFile(filePath: path.Pathlike): boolean
	local fileName = path.format(filePath)
	for _, pattern in DEVELOPMENT_FILE_PATTERNS do
		if fileName:find(pattern) then
			return true
		end
	end
	return false
end

local function getLinkers(folder: path.Pathlike): Linkers
	local linkers: Linkers = {}
	for _, entry in fs.listDirectory(folder) do
		if entry.type ~= "dir" and isLuauFile(entry.name) then
			local name = entry.name:gsub("%.luau?$", "")
			linkers[name] = path.join(folder, entry.name)
		end
	end
	return linkers
end

-- The text between the parentheses of each `require(...)` call in a file.
local function getRequireArguments(filePath: path.Pathlike): { string }
	local requireArguments: { string } = {}
	for requireArgument in fs.readFileToString(filePath):gmatch("require(%b())") do
		table.insert(requireArguments, requireArgument)
	end
	return requireArguments
end

-- Matches `name` only as a whole word, so `React` doesn't match `ReactRoblox`.
local function getWordPattern(name: string): string
	return `%f[%w_]{name:gsub("%p", "%%%0")}%f[^%w_]`
end

--[[
	A manifest can declare a dependency that the shipped code never requires,
	such as a test framework. This walks the requires that the plugin's own
	code makes, then the requires of each package those reach, and removes the
	packages that nothing reached. It returns the names of the `_Index`
	folders it removed.

	The walk reads requires as text. A linker counts as required when its name
	appears as a word inside a `require` call. So a package also stays when
	the code requires one of its own modules that has the same name as a
	linker. A linker goes unnoticed when the code stores it in a variable
	under another name and requires the variable.
]]
local function prunePackagesAsync(options: Options): { string }
	local buildFolder = path.resolve(options.buildFolder)

	local installFolders: { [string]: path.Path } = {}
	for _, name in options.installFolderNames do
		installFolders[name] = path.join(buildFolder, name)
	end

	local reachedPackages: { [string]: boolean } = {}
	local reachPackage: (packagePath: path.Path) -> ()

	--[[
		A linker usually requires a package in `_Index`. `lute run install`
		rewrites some of Rotriever's linkers to require a linker at the top of
		`Packages` instead, so both installs share one copy of React. This
		returns the path the linker requires and whether that path is a package.
		The path is nil when a rewritten linker names a linker that isn't there.
	]]
	local function getLinkerTarget(linkerPath: path.Path): (path.Path?, boolean)
		local requireArgument = getRequireArguments(linkerPath)[1]
		assert(requireArgument, `no require found in the linker at {linkerPath}`)

		local packageName = requireArgument:match('%["([^"]+)"%]%["[^"]+"%]')
		if packageName then
			-- A linker inside a package's folder is two levels below
			-- `_Index`. Any other linker is at the top of an install
			-- folder, beside `_Index`.
			local linkerFolder = path.dirname(linkerPath)
			local indexPath = path.dirname(linkerFolder)
			if path.basename(indexPath) ~= INDEX_NAME then
				indexPath = path.join(linkerFolder, INDEX_NAME)
			end
			return path.join(indexPath, packageName), true
		end

		local folderName, linkerName = requireArgument:match("([%w_]+)%.([%w_]+)%)$")
		local folder = if folderName then installFolders[folderName] else nil
		assert(folder and linkerName, `the linker at {linkerPath} requires something other than a package or a linker`)
		return getLinkers(folder)[linkerName], false
	end

	local function reachLinker(linkerPath: path.Path)
		local target, isPackage = getLinkerTarget(linkerPath)
		if not target then
			return
		elseif isPackage then
			reachPackage(target)
		else
			reachLinker(target)
		end
	end

	reachPackage = function(packagePath: path.Path)
		local key = path.format(packagePath)
		if reachedPackages[key] then
			return
		end
		reachedPackages[key] = true

		local linkers = getLinkers(packagePath)

		-- The files directly inside the package's folder are its linkers.
		-- Only the package's code, in the subfolder, decides which of them
		-- are required.
		for _, descendant in getDescendants(packagePath) do
			if
				not isLuauFile(descendant)
				or isDevelopmentFile(descendant)
				or path.format(path.dirname(descendant)) == key
			then
				continue
			end

			for _, requireArgument in getRequireArguments(descendant) do
				for name, linkerPath in linkers do
					if requireArgument:find(getWordPattern(name)) then
						linkers[name] = nil
						reachLinker(linkerPath)
					end
				end
			end
		end
	end

	-- The plugin's own code is everything outside the install folders. It
	-- requires the linkers at the top of an install folder by naming the
	-- folder, as in `require(script.Parent.Packages.React)`.
	for _, entry in fs.listDirectory(buildFolder) do
		if installFolders[entry.name] then
			continue
		end

		local entryPath = path.join(buildFolder, entry.name)
		local files = if entry.type == "dir" then getDescendants(entryPath) else { entryPath }

		for _, filePath in files do
			if not isLuauFile(filePath) then
				continue
			end

			for _, requireArgument in getRequireArguments(filePath) do
				for folderName, folder in installFolders do
					local prefix = `%f[%w_]{folderName}`
					local linkerName = requireArgument:match(`{prefix}%.([%w_]+)`)
						or requireArgument:match(`{prefix}%["([^"]+)"%]`)
					local linkerPath = if linkerName then getLinkers(folder)[linkerName] else nil

					if linkerPath then
						reachLinker(linkerPath)
					end
				end
			end
		end
	end

	local removedPackages: { string } = {}
	for _, folder in installFolders do
		local indexPath = path.join(folder, INDEX_NAME)

		for _, entry in fs.listDirectory(indexPath) do
			local packagePath = path.join(indexPath, entry.name)

			if entry.type == "dir" and not reachedPackages[path.format(packagePath)] then
				fs.removeDirectory(packagePath, {
					recursive = true,
				})
				table.insert(removedPackages, entry.name)
			end
		end
	end
	table.sort(removedPackages)

	-- A linker left pointing at a removed package would only fail when
	-- required, so it goes too. Removing one can leave another linker that
	-- pointed at it without a target, so this repeats until none are left.
	local function removeBrokenLinkers(folder: path.Path): boolean
		local hasRemoved = false
		for _, linkerPath in getLinkers(folder) do
			local target = getLinkerTarget(linkerPath)
			if not target or not fs.exists(target) then
				fs.remove(linkerPath)
				hasRemoved = true
			end
		end
		return hasRemoved
	end

	local hasRemoved = true
	while hasRemoved do
		hasRemoved = false
		for _, folder in installFolders do
			hasRemoved = removeBrokenLinkers(folder) or hasRemoved

			local indexPath = path.join(folder, INDEX_NAME)
			for _, entry in fs.listDirectory(indexPath) do
				if entry.type == "dir" then
					hasRemoved = removeBrokenLinkers(path.join(indexPath, entry.name)) or hasRemoved
				end
			end
		end
	end

	return removedPackages
end

return prunePackagesAsync
