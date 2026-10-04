local fs = require("@std/fs")
local path = require("@std/path")

export type PendingChanges = {
	total: number,
	byCategory: { [string]: number },
	byBump: { [string]: number },
}

-- Entries without a category land under Changes, matching Changewrite.
local DEFAULT_CATEGORY = "Changes"

local function readFrontmatter(text: string): { [string]: string }
	local fields = {}
	local block = text:gsub("\r\n", "\n"):match("^%s*%-%-%-\n(.-)\n%-%-%-")
	if not block then
		return fields
	end

	for line in block:gmatch("[^\n]+") do
		local key, value = line:match("^%s*([%w_]+)%s*:%s*(.-)%s*$")
		if key and value then
			fields[key] = value:gsub("^[\"'](.*)[\"']$", "%1")
		end
	end
	return fields
end

local function countPendingChanges(dir: string): PendingChanges
	local counts: PendingChanges = { total = 0, byCategory = {}, byBump = {} }
	if not fs.exists(dir) then
		return counts
	end

	for _, entry in fs.listDirectory(dir) do
		local name = string.lower(entry.name)
		if entry.type ~= "file" or path.extname(name) ~= ".md" or name == "readme.md" then
			continue
		end

		local fields = readFrontmatter(fs.readFileToString(path.join(dir, entry.name)))
		local category = fields.category or DEFAULT_CATEGORY
		local bump = fields.bump or "unknown"

		counts.total += 1
		counts.byCategory[category] = (counts.byCategory[category] or 0) + 1
		counts.byBump[bump] = (counts.byBump[bump] or 0) + 1
	end

	return counts
end

return countPendingChanges
