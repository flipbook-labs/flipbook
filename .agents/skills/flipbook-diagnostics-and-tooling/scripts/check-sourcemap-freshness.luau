#!/usr/bin/env lute
-- Check whether sourcemaps are fresh relative to their source files.
-- Run from the repo root: lute run .agents/skills/flipbook-diagnostics-and-tooling/scripts/check-sourcemap-freshness.luau
-- Reports whether each sourcemap is newer than the newest source file it covers.

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

local function modifiedSeconds(filePath: string): number?
	if not fs.exists(filePath) then
		return nil
	end
	return fs.metadata(filePath).modified:toSeconds()
end

local function newestSourceSeconds(sourceDir: string): number
	local newest = 0
	local function scan(dir: string)
		for _, entry in fs.listDirectory(dir) do
			local entryPath = path.join(dir, entry.name)
			if entry.type == "file" and string.match(entry.name, "%.luau$") then
				local t = modifiedSeconds(entryPath)
				if t and t > newest then
					newest = t
				end
			elseif entry.type == "dir" and not string.match(entry.name, "^%.") and entry.name ~= "build" then
				scan(entryPath)
			end
		end
	end
	scan(sourceDir)
	return newest
end

local function checkSourcemap(sourcemapPath: string, sourceDir: string): (boolean?, string)
	if not fs.exists(sourcemapPath) then
		return nil, "sourcemap not found"
	end
	if not fs.exists(sourceDir) then
		return nil, "source directory not found"
	end

	local sourcemapTime = modifiedSeconds(sourcemapPath)
	if not sourcemapTime then
		return nil, "cannot read sourcemap time"
	end

	local newestSource = newestSourceSeconds(sourceDir)
	if newestSource > sourcemapTime then
		return false, string.format("sourcemap older than source (diff: %.1f sec)", newestSource - sourcemapTime)
	end

	return true, "sourcemap is fresh"
end

print("\n=== Sourcemap Freshness Check ===\n")

local checks = {
	{
		name = "workspace/flipbook-core",
		sourcemap = path.join(PROJECT_ROOT, "workspace/flipbook-core/sourcemap.json"),
		source = path.join(PROJECT_ROOT, "workspace/flipbook-core/src"),
	},
	{
		name = "root project",
		sourcemap = path.join(PROJECT_ROOT, "sourcemap.json"),
		source = path.join(PROJECT_ROOT, "workspace"),
	},
}

local allFresh = true

for _, check in ipairs(checks) do
	local fresh, msg = checkSourcemap(check.sourcemap, check.source)

	if fresh == nil then
		print(string.format("⚠️  %s: %s", check.name, msg))
	elseif fresh then
		print(string.format("✅ %s: %s", check.name, msg))
	else
		print(string.format("❌ %s: %s", check.name, msg))
		allFresh = false
	end
end

if allFresh then
	print("\n✅ All sourcemaps are fresh\n")
else
	print("\n⚠️  Some sourcemaps may be stale — rebuild with: lute run build --clean\n")
end
