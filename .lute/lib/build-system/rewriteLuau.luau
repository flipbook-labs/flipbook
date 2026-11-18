local fs = require("@std/fs")
local json = require("@std/json")
local luau = require("@std/luau")
local path = require("@std/path")
local printer = require("@std/syntax/printer")
local query = require("@std/syntax/query")
local syntax = require("@std/syntax")
local utils = require("@std/syntax/utils")

-- Source files use Luau string requires, such as `require("@pkg/React")` or
-- `require("./Foo")`. This rewrites them into the instance requires Roblox
-- runs, like `require(script.Parent.Packages.React)`, and replaces reads of
-- build globals such as `_G.BUILD_CHANNEL` with their values for this build.
--
-- A require is resolved the way Luau resolves it on disk: relative paths and
-- `@self` from the requiring file, and aliases from the nearest `.config.luau`
-- or `.luaurc` above it. A Rojo sourcemap then says which instance each file
-- becomes. Every path here is relative to `repoPath` and uses `/`.

export type SourcemapNode = {
	name: string,
	filePaths: { string }?,
	children: { SourcemapNode }?,
}

export type Options = {
	repoPath: string,
	-- A sourcemap from `rojo sourcemap` for the project the build output syncs
	-- into, where the root instance is the one the output folder becomes.
	sourcemap: SourcemapNode,
	-- Names of the `_G` globals to replace. A global with no value becomes `nil`.
	globalNames: { string },
	globalValues: { [string]: string },
}

export type Rewriter = {
	options: Options,
	-- Instance paths, as names from the sourcemap root, for each module file
	-- and for each folder a module sits in.
	moduleByFile: { [string]: { string } },
	instanceByFolder: { [string]: { string } },
	aliasesByFolder: { [string]: { [string]: string } },
}

local function normalize(filePath: string): string
	local parts = {}
	for _, part in string.split((filePath:gsub("\\", "/")), "/") do
		if part == ".." and #parts > 0 and parts[#parts] ~= ".." then
			table.remove(parts)
		elseif part ~= "." and part ~= "" then
			table.insert(parts, part)
		end
	end
	return table.concat(parts, "/")
end

local function dirname(filePath: string): string
	return filePath:match("^(.*)/[^/]*$") or ""
end

local function join(base: string, relative: string): string
	return normalize(if base == "" then relative else `{base}/{relative}`)
end

local function isInit(filePath: string): boolean
	return filePath:match("/init%.[%w%.]+$") ~= nil or filePath:match("^init%.[%w%.]+$") ~= nil
end

local function indexSourcemap(rewriter: Rewriter, node: SourcemapNode, instancePath: { string })
	for _, filePath in node.filePaths or {} do
		local file = normalize(filePath)
		if file:match("%.luau?$") then
			rewriter.moduleByFile[file] = instancePath
			if isInit(file) then
				rewriter.instanceByFolder[dirname(file)] = instancePath
			end
		end
	end

	for _, child in node.children or {} do
		local childPath = table.clone(instancePath)
		table.insert(childPath, child.name)
		indexSourcemap(rewriter, child, childPath)

		-- A folder without an init file has no file of its own in the
		-- sourcemap, so it's found through the files directly inside it.
		for _, filePath in child.filePaths or {} do
			local file = normalize(filePath)
			if file:match("%.luau?$") and not isInit(file) and rewriter.instanceByFolder[dirname(file)] == nil then
				rewriter.instanceByFolder[dirname(file)] = instancePath
			end
		end
	end
end

local function readAliases(rewriter: Rewriter, folder: string): { [string]: string }
	local cached = rewriter.aliasesByFolder[folder]
	if cached then
		return cached
	end

	local aliases = {}
	local absolute = path.join(rewriter.options.repoPath, folder)
	local configPath = path.join(absolute, ".config.luau")
	local luaurcPath = path.join(absolute, ".luaurc")

	local config: any = nil
	if fs.exists(configPath) then
		config = (luau.loadModule(path.format(configPath)) :: any).luau
	elseif fs.exists(luaurcPath) then
		config = json.deserialize(fs.readFileToString(luaurcPath))
	end

	local configAliases: { [unknown]: unknown } = if config and config.aliases then config.aliases else {}
	for name, value in configAliases do
		-- Home-relative aliases point at Lute tooling, which never reaches
		-- Roblox. Decoded JSON objects also carry a marker key, which is skipped.
		if typeof(name) == "string" and typeof(value) == "string" and not value:match("^~") then
			aliases[string.lower(name)] = join(folder, value)
		end
	end

	rewriter.aliasesByFolder[folder] = aliases
	return aliases
end

-- The nearest config that defines an alias wins, as in Luau.
local function resolveAlias(rewriter: Rewriter, fromFolder: string, alias: string): string?
	local folder: string? = fromFolder
	while folder do
		local target = readAliases(rewriter, folder)[string.lower(alias)]
		if target then
			return target
		end
		folder = if folder == "" then nil else dirname(folder)
	end
	return nil
end

-- Returns the file or folder a require string points at, without extension.
local function resolveRequirePath(rewriter: Rewriter, requirer: string, requirePath: string): string
	-- A module's own path is its folder when it's an init file. `./` and `../`
	-- start from the folder that path sits in, and `@self` from the path itself.
	local modulePath = if isInit(requirer) then dirname(requirer) else (requirer:gsub("%.[%w%.]+$", ""))

	local alias, rest = requirePath:match("^@([^/]+)/?(.*)$")
	if alias == "self" and rest then
		return join(modulePath, rest)
	elseif alias and rest then
		local target = resolveAlias(rewriter, dirname(requirer), alias)
		assert(target, `{requirer}: unknown alias "@{alias}" in require("{requirePath}")`)
		return join(target, rest)
	end

	assert(requirePath:match("^%.%.?/"), `{requirer}: require("{requirePath}") must start with ./, ../ or @`)
	return join(dirname(modulePath), requirePath)
end

local function findInstance(rewriter: Rewriter, target: string): { string }?
	for _, candidate in { `{target}.luau`, `{target}.lua`, `{target}/init.luau`, `{target}/init.lua` } do
		local instance = rewriter.moduleByFile[candidate]
		if instance then
			return instance
		end
	end
	return rewriter.instanceByFolder[target]
end

-- Builds `script.Parent...` from one instance to another.
local function relativeInstancePath(from: { string }, to: { string }): string
	local shared = 0
	while shared < #from and shared < #to and from[shared + 1] == to[shared + 1] do
		shared += 1
	end

	local expression = "script" .. string.rep(".Parent", #from - shared)
	for index = shared + 1, #to do
		local name = to[index]
		expression ..= if name:match("^[%a_][%w_]*$") then `.{name}` else `[{string.format("%q", name)}]`
	end
	return expression
end

local function quote(value: string?): string
	return if value == nil then "nil" else (string.format("%q", value):gsub("\\\n", "\\n"))
end

local function create(options: Options): Rewriter
	local rewriter: Rewriter = {
		options = options,
		moduleByFile = {},
		instanceByFolder = {},
		aliasesByFolder = {},
	}
	indexSourcemap(rewriter, options.sourcemap, {})
	return rewriter
end

-- `requirer` is the source file's path relative to the repo.
local function rewriteSource(rewriter: Rewriter, source: string, requirer: string): string
	local requirerInstance = rewriter.moduleByFile[requirer]
	local isGlobal: { [string]: boolean } = {}
	for _, name in rewriter.options.globalNames do
		isGlobal[name] = true
	end

	local parsed = syntax.parse(source)
	local replacements = query
		.findAllFromRoot(parsed, utils.isRequireCall)
		:filter(function(call)
			local argument = call.arguments[1]
			return #call.arguments == 1 and argument.kind == "expr" and argument.tag == "string"
		end)
		:replace(function(call)
			assert(requirerInstance, `{requirer} isn't in the build sourcemap, so its requires can't be resolved`)
			local requirePath = (call.arguments[1] :: syntax.CstExprConstantString).value.text
			local target = resolveRequirePath(rewriter, requirer, requirePath)
			local instance = findInstance(rewriter, target)
			assert(instance, `{requirer}: require("{requirePath}") resolves to {target}, which isn't in the sourcemap`)
			return `require({relativeInstancePath(requirerInstance, instance)})`
		end)

	query
		.findAllFromRoot(parsed, utils.isExprIndexName)
		:filter(function(index)
			local global = utils.isExprGlobal(index.expression)
			return global ~= nil and global.name.text == "_G" and isGlobal[index.index.text] == true
		end)
		:forEach(function(index)
			replacements[index] = quote(rewriter.options.globalValues[index.index.text])
		end)

	return if next(replacements) then printer.printFile(parsed, replacements) else source
end

-- Copies `sourceFolder` into `destFolder`, rewriting each Luau file on the way.
local function rewriteFolder(rewriter: Rewriter, sourceFolder: path.Pathlike, destFolder: path.Pathlike)
	local repoPath = rewriter.options.repoPath
	for entry in fs.walk(sourceFolder, { recursive = true }) do
		if fs.type(entry) ~= "file" then
			continue
		end

		local relative = normalize(tostring(path.relative(sourceFolder, entry)))
		local dest = path.join(destFolder, relative)
		fs.createDirectory(path.dirname(dest), { makeParents = true })

		local file = normalize(tostring(path.relative(repoPath, entry)))
		if file:match("%.luau?$") then
			fs.writeStringToFile(dest, rewriteSource(rewriter, fs.readFileToString(entry), file))
		else
			fs.copy(entry, dest)
		end
	end
end

return {
	create = create,
	rewriteSource = rewriteSource,
	rewriteFolder = rewriteFolder,
	relativeInstancePath = relativeInstancePath,
}
