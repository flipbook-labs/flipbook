#!/usr/bin/env lute
-- Inventory all stories and specs in the workspace.
-- Run from the repo root: lute run .agents/skills/flipbook-diagnostics-and-tooling/scripts/inventory-stories.luau
-- Outputs a summary of story/spec counts per workspace member.

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

local WORKSPACE_ROOT = path.join(findRepoRoot(), "workspace")

local function countMatching(dir: string, pattern: string): number
	if not fs.exists(dir) then
		return 0
	end

	local count = 0
	for _, entry in fs.listDirectory(dir) do
		local entryPath = path.join(dir, entry.name)
		if entry.type == "file" then
			if string.match(entry.name, pattern) then
				count += 1
			end
		elseif entry.type == "dir" then
			count += countMatching(entryPath, pattern)
		end
	end
	return count
end

local members = {}

for _, entry in fs.listDirectory(WORKSPACE_ROOT) do
	if entry.type == "dir" and not string.match(entry.name, "^%.") then
		local memberPath = path.join(WORKSPACE_ROOT, entry.name)
		table.insert(members, {
			name = entry.name,
			stories = countMatching(memberPath, "%.story%.luau$"),
			specs = countMatching(memberPath, "%.spec%.luau$"),
		})
	end
end

table.sort(members, function(a, b)
	return a.name < b.name
end)

print("\n=== Flipbook Story & Spec Inventory ===\n")
print(string.format("%-30s %10s %10s", "Workspace Member", "Stories", "Specs"))
print(string.rep("-", 52))

local totalStories = 0
local totalSpecs = 0

for _, member in ipairs(members) do
	print(string.format("%-30s %10d %10d", member.name, member.stories, member.specs))
	totalStories += member.stories
	totalSpecs += member.specs
end

print(string.rep("-", 52))
print(string.format("%-30s %10d %10d\n", "TOTAL", totalStories, totalSpecs))
