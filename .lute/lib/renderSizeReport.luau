--[[
	A size report lists how big each thing Flipbook builds is, in bytes.
	`lute run size-report` measures one and saves it as JSON, and this module
	turns it into the Markdown that CI posts on a pull request.
]]

export type Bundle = {
	-- What the reader sees, such as `Plugin (prod)`.
	name: string,
	bytes: number,
}

export type Part = {
	-- A folder inside the built plugin, such as `Packages`.
	name: string,
	-- The part's size in each channel that has it. A prod build leaves the
	-- development-only workspace members out, so those have no prod size.
	bytes: { [string]: number },
}

export type Report = {
	-- The files that get published or deployed.
	bundles: { Bundle },
	-- The channels the plugin was built for, in the order to show them.
	channels: { string },
	-- What the plugin is made of.
	parts: { Part },
	-- How much the storybook deploy uploads at once: the storybook place plus
	-- the prod plugin.
	storybookDeployBytes: number,
}

-- A comment that starts with this line is the size report. CI looks for it to
-- update the comment it already posted instead of adding another.
local MARKER = "<!-- size-report -->"

--[[
	Roblox rejects a storybook deploy when its place and plugin are too large
	together. The limit isn't documented. This is the largest deploy seen to
	go through, and one of 8,362,766 bytes failed with "Form data is null".
]]
local LARGEST_STORYBOOK_DEPLOY_BYTES = 8_358_101

local MINUS = "−"

local function formatBytes(bytes: number): string
	if bytes >= 1_000_000 then
		return `{("%.2f"):format(bytes / 1_000_000)} MB`
	elseif bytes >= 1_000 then
		return `{("%.1f"):format(bytes / 1_000)} kB`
	else
		return `{bytes} B`
	end
end

-- How a size changed from `baseBytes`, such as `+12.3 kB`.
local function formatChange(bytes: number, baseBytes: number): string
	local change = bytes - baseBytes
	if change == 0 then
		return "no change"
	end
	return `{if change > 0 then "+" else MINUS}{formatBytes(math.abs(change))}`
end

-- The same change as a share of `baseBytes`, such as `+0.4%`.
local function formatPercentChange(bytes: number, baseBytes: number): string
	local change = bytes - baseBytes
	return `{if change > 0 then "+" else MINUS}{("%.1f"):format(math.abs(change) / baseBytes * 100)}%`
end

local function capitalize(text: string): string
	local capitalized = text:gsub("^%l", string.upper)
	return capitalized
end

--[[
	Renders `report` as Markdown. `baseReport` is the report from `main`, and
	each size is shown with how it changed from there. Something `baseReport`
	doesn't have is marked as new. Without a `baseReport` the sizes stand alone.
]]
local function renderSizeReport(report: Report, baseReport: Report?): string
	local lines = { MARKER, "## Bundle size", "" }

	local baseBundles: { [string]: Bundle } = {}
	local baseParts: { [string]: Part } = {}
	if baseReport then
		for _, bundle in baseReport.bundles do
			baseBundles[bundle.name] = bundle
		end
		for _, part in baseReport.parts do
			baseParts[part.name] = part
		end
	end

	if baseReport then
		table.insert(lines, "| Bundle | Size | Change from `main` |")
		table.insert(lines, "| --- | ---: | ---: |")
	else
		table.insert(lines, "| Bundle | Size |")
		table.insert(lines, "| --- | ---: |")
	end

	for _, bundle in report.bundles do
		local row = `| {bundle.name} | {formatBytes(bundle.bytes)} |`
		if baseReport then
			local baseBundle = baseBundles[bundle.name]
			local change = "new"
			if baseBundle then
				change = formatChange(bundle.bytes, baseBundle.bytes)
				if bundle.bytes ~= baseBundle.bytes and baseBundle.bytes > 0 then
					change ..= ` ({formatPercentChange(bundle.bytes, baseBundle.bytes)})`
				end
			end
			row ..= ` {change} |`
		end
		table.insert(lines, row)
	end

	if not baseReport then
		table.insert(lines, "")
		table.insert(lines, "There's no report from `main` to compare with yet.")
	end

	table.insert(lines, "")
	table.insert(
		lines,
		`The storybook deploy on \`main\` uploads the storybook place and the prod plugin together. That's {formatBytes(
			report.storybookDeployBytes
		)} of the {formatBytes(LARGEST_STORYBOOK_DEPLOY_BYTES)} that Roblox is known to accept.`
	)

	local header = { "Part" }
	local divider = { "---" }
	for _, channel in report.channels do
		table.insert(header, capitalize(channel))
		table.insert(divider, "---:")
	end

	table.insert(lines, "")
	table.insert(lines, "### What the plugin is made of")
	table.insert(lines, "")
	table.insert(lines, `| {table.concat(header, " | ")} |`)
	table.insert(lines, `| {table.concat(divider, " | ")} |`)

	for _, part in report.parts do
		local basePart = baseParts[part.name]
		local cells = { `\`{part.name}\`` }

		for _, channel in report.channels do
			local bytes = part.bytes[channel]
			local cell = if bytes then formatBytes(bytes) else "–"

			-- A part that didn't change gets no note, which keeps the table
			-- readable when a pull request moves one or two of them.
			if bytes and baseReport then
				local baseBytes = if basePart then basePart.bytes[channel] else nil
				if not baseBytes then
					cell ..= " (new)"
				elseif baseBytes ~= bytes then
					cell ..= ` ({formatChange(bytes, baseBytes)})`
				end
			end

			table.insert(cells, cell)
		end

		table.insert(lines, `| {table.concat(cells, " | ")} |`)
	end

	table.insert(lines, "")
	table.insert(
		lines,
		"Each part is its size as a model file of its own, so the parts don't add up exactly to the plugin."
	)

	return table.concat(lines, "\n") .. "\n"
end

return renderSizeReport
