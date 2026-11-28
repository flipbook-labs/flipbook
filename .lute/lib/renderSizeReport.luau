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

-- The size of every bundle at one commit, keyed by the bundle's name.
export type HistoryEntry = {
	sha: string,
	bytes: { [string]: number },
}

export type Report = {
	-- The commit that was measured, as a short hash.
	sha: string,
	-- The files that get published or deployed.
	bundles: { Bundle },
	-- The channels the plugin was built for, in the order to show them.
	channels: { string },
	-- What the plugin is made of.
	parts: { Part },
	-- How much the storybook deploy uploads at once: the storybook place plus
	-- the prod plugin.
	storybookDeployBytes: number,
	-- The reports from `main` that came before this one, oldest first, and
	-- then this report itself.
	history: { HistoryEntry },
}

export type Options = {
	-- The CI run that measured the report, which the footer links to.
	runUrl: string?,
}

type Direction = "bigger" | "smaller" | "same"

-- A comment that starts with this line is the size report. CI looks for it to
-- update the comment it already posted instead of adding another.
local MARKER = "<!-- size-report -->"

-- The bundle people install, which the charts are about.
local PROD_PLUGIN_NAME = "Plugin (prod)"
local PROD_CHANNEL = "prod"

--[[
	Roblox rejects a storybook deploy when its place and plugin are too large
	together. The limit isn't documented. This is the largest deploy seen to
	go through, and one of 8,362,766 bytes failed with "Form data is null".
]]
local LARGEST_STORYBOOK_DEPLOY_BYTES = 8_358_101

--[[
	Two builds of the same code can differ by a few bytes, because the commit
	hash is compiled in and compresses differently. A change smaller than this
	share of the base size is shown but doesn't count as bigger or smaller.
]]
local NOISE_RATIO = 0.001

-- The line chart shows this many of the latest commits, which is about what
-- fits along its axis.
local MAX_CHART_POINTS = 12

-- A part smaller than this share of the plugin is folded into one bar of the
-- parts chart.
local SMALL_PART_RATIO = 0.01

--[[
	GitHub draws a Mermaid chart as wide as the comment, whatever size the
	chart asks for, and scales everything in it to fit. So the width here
	sets how big the chart's text and bars look: a comment is about 900
	pixels wide, and a chart 1,400 wide is drawn at about two thirds of its
	size. The height then sets the chart's shape. Both charts are Mermaid's
	XY chart because it's the kind that takes a size.
]]
local CHART_WIDTH = 1400

local function getChartSize(height: number): string
	return `%%\{init: \{"xyChart": \{"width": {CHART_WIDTH}, "height": {height}}}}%%`
end

local CHART_SIZES = {
	history = getChartSize(270),
	parts = getChartSize(220),
}

local BAR_LENGTH = 20
local MINUS = "−"

local DIRECTION_ICONS: { [Direction]: string } = {
	bigger = "🟠",
	smaller = "🟢",
	same = "⚪",
}

local function formatBytes(bytes: number): string
	if bytes >= 1_000_000 then
		return `{("%.2f"):format(bytes / 1_000_000)} MB`
	elseif bytes >= 1_000 then
		return `{("%.1f"):format(bytes / 1_000)} kB`
	else
		return `{bytes} B`
	end
end

local function formatMegabytes(bytes: number): string
	return ("%.2f"):format(bytes / 1_000_000)
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

-- Whether a size is bigger or smaller than `baseBytes`, or the same when the
-- change is too small to mean anything.
local function getDirection(bytes: number, baseBytes: number): Direction
	if math.abs(bytes - baseBytes) <= baseBytes * NOISE_RATIO then
		return "same"
	end
	return if bytes > baseBytes then "bigger" else "smaller"
end

-- Whether a change is more worth calling out than the one found so far. Any
-- growth outranks any shrinking, and otherwise the larger change wins.
local function outranks(direction: Direction, change: number, otherDirection: Direction, otherChange: number): boolean
	if direction == "same" then
		return false
	elseif direction == otherDirection then
		return change > otherChange
	end
	return direction == "bigger" or otherDirection == "same"
end

local function capitalize(text: string): string
	local capitalized = text:gsub("^%l", string.upper)
	return capitalized
end

local function pluralize(count: number, noun: string): string
	return `{count} {noun}{if count == 1 then "" else "s"}`
end

--[[
	Renders `report` as Markdown. `baseReport` is the latest report from
	`main`, and each size is shown beside the one from there. Without a
	`baseReport` the same columns are there, with nothing in them.
]]
local function renderSizeReport(report: Report, baseReport: Report?, options: Options?): string
	local lines = { MARKER, "## 📦 Bundle size", "" }

	local function add(line: string)
		table.insert(lines, line)
	end

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

	--[[
		The verdict under the heading, and a callout when a bundle moved. The
		callout names the bundle that grew the most, since that's the one a
		reviewer should look at first. When nothing grew, it names the one
		that shrank the most.
	]]
	if baseReport then
		local counts: { [Direction]: number } = {
			bigger = 0,
			smaller = 0,
			same = 0,
		}
		local largest: Bundle? = nil
		local largestChange = 0
		local largestDirection: Direction = "same"

		for _, bundle in report.bundles do
			local baseBundle = baseBundles[bundle.name]
			if not baseBundle then
				continue
			end

			local direction = getDirection(bundle.bytes, baseBundle.bytes)
			counts[direction] += 1

			local change = math.abs(bundle.bytes - baseBundle.bytes)
			if outranks(direction, change, largestDirection, largestChange) then
				largest = bundle
				largestChange = change
				largestDirection = direction
			end
		end

		local verdicts: { string } = {}
		if counts.bigger > 0 then
			table.insert(verdicts, `{counts.bigger} bigger`)
		end
		if counts.smaller > 0 then
			table.insert(verdicts, `{counts.smaller} smaller`)
		end
		if counts.same > 0 then
			table.insert(verdicts, `{counts.same} unchanged`)
		end

		local bundleCount = pluralize(#report.bundles, "bundle")
		add(
			`Comparing \`{report.sha}\` with \`main\` at \`{baseReport.sha}\` across {bundleCount}: {table.concat(
				verdicts,
				", "
			)}.`
		)

		if largest then
			local baseBytes = baseBundles[largest.name].bytes
			local way = if largest.bytes > baseBytes then "up" else "down"
			local change = `{way} {formatBytes(largestChange)} ({formatPercentChange(largest.bytes, baseBytes)})`

			add("")
			if counts.bigger > 0 then
				add("> [!WARNING]")
				add(
					`> 📈 **{pluralize(counts.bigger, "bundle")} got bigger.** The largest change is {largest.name}, {change}.`
				)
			else
				add("> [!TIP]")
				add(
					`> 📉 **{pluralize(counts.smaller, "bundle")} got smaller.** The largest change is {largest.name}, {change}.`
				)
			end
		end
	else
		add(
			`Measured \`{report.sha}\`. There's no report from \`main\` yet, so the columns that compare with it are empty.`
		)
	end

	add("")
	add("### 🚢 What gets shipped")
	add("")
	add("|  | Bundle | `main` | This commit | Change |")
	add("| :-: | --- | ---: | ---: | ---: |")

	for _, bundle in report.bundles do
		local baseBundle = baseBundles[bundle.name]
		local icon, baseSize, change = "", "", ""

		if baseBundle then
			local direction = getDirection(bundle.bytes, baseBundle.bytes)
			icon = DIRECTION_ICONS[direction]
			baseSize = formatBytes(baseBundle.bytes)
			change = formatChange(bundle.bytes, baseBundle.bytes)
			if direction ~= "same" then
				change = `**{change}** ({formatPercentChange(bundle.bytes, baseBundle.bytes)})`
			end
		elseif baseReport then
			icon = "🆕"
			change = "new"
		end

		add(`| {icon} | {bundle.name} | {baseSize} | {formatBytes(bundle.bytes)} | {change} |`)
	end

	-- A bar showing how close the storybook deploy is to the largest one that
	-- has gone through. It turns yellow and then red as the room runs out.
	local deployRatio = report.storybookDeployBytes / LARGEST_STORYBOOK_DEPLOY_BYTES
	local filled = math.clamp(math.round(deployRatio * BAR_LENGTH), 0, BAR_LENGTH)
	local square = if deployRatio >= 0.9 then "🟥" elseif deployRatio >= 0.75 then "🟨" else "🟩"
	local deploySize = formatBytes(report.storybookDeployBytes)

	add("")
	add("### 🎈 Room left in the storybook deploy")
	add("")
	add(
		`{square:rep(filled)}{("⬜"):rep(BAR_LENGTH - filled)} **{math.round(deployRatio * 100)}%** · {deploySize} of {formatBytes(
			LARGEST_STORYBOOK_DEPLOY_BYTES
		)}`
	)
	add("")
	add(
		"The deploy on `main` uploads the storybook place and the prod plugin together, and Roblox rejects the two once they pass about this size."
	)

	--[[
		A line chart of the prod plugin's size at the latest commits on
		`main`, with the commit this report measured at the end. One commit
		doesn't make a line, so until there are two this says when the chart
		will show up.
	]]
	local chartLabels: { string }, chartSizes: { string } = {}, {}
	local largestBytes = 0
	for index = math.max(1, #report.history - MAX_CHART_POINTS + 1), #report.history do
		local entry = report.history[index]
		local bytes = entry.bytes[PROD_PLUGIN_NAME]
		if bytes then
			table.insert(chartLabels, `"{entry.sha}"`)
			table.insert(chartSizes, formatMegabytes(bytes))
			largestBytes = math.max(largestBytes, bytes)
		end
	end

	add("")
	add("### 📈 Prod plugin over time")
	add("")
	if #chartSizes >= 2 then
		add("```mermaid")
		add(CHART_SIZES.history)
		add("xychart-beta")
		add(`    x-axis [{table.concat(chartLabels, ", ")}]`)
		add(`    y-axis "Size (MB)" 0 --> {math.ceil(largestBytes / 1_000_000)}`)
		add(`    line [{table.concat(chartSizes, ", ")}]`)
		add("```")
		add("")
		add(`The latest commits on \`main\`, with \`{report.sha}\` at the end.`)
	else
		add("_A chart of the size at each commit shows up here once `main` has a report to start from._")
	end

	local prodBytes = 0
	for _, part in report.parts do
		prodBytes += part.bytes[PROD_CHANNEL] or 0
	end

	add("")
	add("### 🧩 What the prod plugin is made of")
	add("")
	-- One bar for each part of the prod plugin, biggest first, with the
	-- small parts added up into a last bar.
	local prodParts: { Part } = {}
	local otherBytes = 0
	for _, part in report.parts do
		local bytes = part.bytes[PROD_CHANNEL]
		if not bytes then
			continue
		elseif bytes < prodBytes * SMALL_PART_RATIO then
			otherBytes += bytes
		else
			table.insert(prodParts, part)
		end
	end
	table.sort(prodParts, function(a: Part, b: Part)
		return a.bytes[PROD_CHANNEL] > b.bytes[PROD_CHANNEL]
	end)

	local barLabels: { string }, barSizes: { string } = {}, {}
	local largestPartBytes = otherBytes
	for _, part in prodParts do
		local bytes = part.bytes[PROD_CHANNEL]
		table.insert(barLabels, `"{part.name}"`)
		table.insert(barSizes, formatMegabytes(bytes))
		largestPartBytes = math.max(largestPartBytes, bytes)
	end
	if otherBytes > 0 then
		table.insert(barLabels, '"Everything else"')
		table.insert(barSizes, formatMegabytes(otherBytes))
	end

	add("```mermaid")
	add(CHART_SIZES.parts)
	add("xychart-beta horizontal")
	add(`    x-axis [{table.concat(barLabels, ", ")}]`)
	add(`    y-axis "Size (MB)" 0 --> {math.ceil(largestPartBytes / 1_000_000)}`)
	add(`    bar [{table.concat(barSizes, ", ")}]`)
	add("```")

	local header = { "Part" }
	local divider = { "---" }
	for _, channel in report.channels do
		table.insert(header, capitalize(channel))
		table.insert(divider, "---:")
	end

	add("")
	add("<details>")
	add(`<summary>🔬 <b>Every part in every channel</b> · {pluralize(#report.parts, "part")}</summary>`)
	add("")
	add("A part that changed from `main` shows by how much. A dash means the channel leaves that part out.")
	add("")
	add(`| {table.concat(header, " | ")} |`)
	add(`| {table.concat(divider, " | ")} |`)

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
					cell ..= " 🆕"
				else
					local direction = getDirection(bytes, baseBytes)
					if direction ~= "same" then
						cell ..= ` {DIRECTION_ICONS[direction]} {formatChange(bytes, baseBytes)}`
					end
				end
			end

			table.insert(cells, cell)
		end

		add(`| {table.concat(cells, " | ")} |`)
	end

	add("")
	add("</details>")

	local runUrl = if options then options.runUrl else nil
	local measured = if runUrl then `Measured {report.sha} in [this run]({runUrl}).` else `Measured {report.sha}.`

	add("")
	add(
		`<sub>{measured} Each part is measured as a model file of its own, so the parts don't add up exactly to the plugin. Changes under 0.1% count as unchanged. Each push replaces this comment.</sub>`
	)

	return table.concat(lines, "\n") .. "\n"
end

return renderSizeReport
