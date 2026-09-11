#!/usr/bin/env lute
-- Detect environment-variable drift by scanning source files.
-- Run from the repo root: lute run .agents/skills/flipbook-diagnostics-and-tooling/scripts/detect-env-drift.luau
-- Compares process.env reads in code against .env.template declarations.

local fs = require("@std/fs")
local path = require("@std/path")

-- Resolve the repo root from this script's own location (walk up to the rokit.toml
-- marker) so the script works from any working directory and any clone.
local function findRepoRoot()
	local dir = path.dirname(debug.info(1, "s"))
	for _ = 1, 12 do
		if fs.exists(path.join(dir, "rokit.toml")) then
			return dir
		end
		local parent = path.dirname(dir)
		if parent == dir then
			break
		end
		dir = parent
	end
	error("could not locate repo root (no rokit.toml found above this script)")
end

local PROJECT_ROOT = findRepoRoot()
local ENV_TEMPLATE = path.join(PROJECT_ROOT, ".env.template")

-- Variables declared in .env.template
local templateVars = {}
if fs.exists(ENV_TEMPLATE) then
	for line in string.gmatch(fs.readFileToString(ENV_TEMPLATE), "[^\n]+") do
		local var = string.match(line, "^([A-Z_][A-Z0-9_]*)=")
		if var then
			templateVars[var] = true
		end
	end
end

-- process.env reads found in code
local envReads = {}

local function scanFile(filePath: string)
	for line in string.gmatch(fs.readFileToString(filePath), "[^\n]+") do
		local var = string.match(line, "process%.env%.([A-Z_][A-Z0-9_]*)")
		if var then
			envReads[var] = (envReads[var] or 0) + 1
		end
	end
end

local function scanDirectory(dir: string)
	if not fs.exists(dir) then
		return
	end
	for _, entry in fs.listDirectory(dir) do
		local entryPath = path.join(dir, entry.name)
		if entry.type == "file" and string.match(entry.name, "%.luau$") then
			scanFile(entryPath)
		elseif entry.type == "dir" and not string.match(entry.name, "^%.") then
			scanDirectory(entryPath)
		end
	end
end

scanDirectory(path.join(PROJECT_ROOT, "workspace"))
-- The .lute build/test scripts read env vars too.
scanDirectory(path.join(PROJECT_ROOT, ".lute"))

print("\n=== Environment Variable Drift Detection ===\n")

-- Used in code but not declared in the template
local undeclared = {}
for var, count in pairs(envReads) do
	if not templateVars[var] then
		table.insert(undeclared, { var = var, count = count })
	end
end

if #undeclared > 0 then
	table.sort(undeclared, function(a, b)
		return a.count > b.count
	end)
	print("⚠️  UNDECLARED (used in code but not in .env.template):\n")
	for _, item in ipairs(undeclared) do
		print(string.format("  %s (used %d times)", item.var, item.count))
	end
	print("")
end

-- Declared in the template but never read
local unused = {}
for var in pairs(templateVars) do
	if not envReads[var] then
		table.insert(unused, var)
	end
end

if #unused > 0 then
	table.sort(unused)
	print("ℹ️  UNUSED (in .env.template but never read in code):\n")
	for _, var in ipairs(unused) do
		print(string.format("  %s", var))
	end
	print("")
end

local declaredCount = 0
for _ in pairs(templateVars) do
	declaredCount += 1
end
local readCount = 0
for _ in pairs(envReads) do
	readCount += 1
end
print(string.format("Summary: %d env vars declared, %d vars read from code", declaredCount, readCount))

if #undeclared > 0 or #unused > 0 then
	print("❌ Drift detected\n")
else
	print("✅ No drift\n")
end
