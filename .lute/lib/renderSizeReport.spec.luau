local test = require("@std/test")

local renderSizeReport = require("./renderSizeReport")

type Report = renderSizeReport.Report

local function getReport(): Report
	return {
		sha = "bbbbbbb",
		bundles = {
			{ name = "Plugin (prod)", bytes = 2_500_000 },
			{ name = "Storybook place", bytes = 4_000_000 },
		},
		channels = { "prod", "dev" },
		parts = {
			{ name = "Packages", bytes = { prod = 800_000, dev = 2_000_000 } },
			{ name = "workspace/example", bytes = { dev = 7_000 } },
			{ name = "workspace/flipbook-next", bytes = { prod = 6_000, dev = 6_000 } },
			{ name = "src", bytes = { prod = 900, dev = 900 } },
		},
		storybookDeployBytes = 6_500_000,
		history = {
			{ sha = "bbbbbbb", bytes = { ["Plugin (prod)"] = 2_500_000 } },
		},
	}
end

local function getBaseReport(): Report
	local baseReport = getReport()
	baseReport.sha = "aaaaaaa"
	return baseReport
end

local function hasLine(markdown: string, line: string): boolean
	return (`\n{markdown}`):find(`\n{line}\n`, 1, true) ~= nil
end

local function hasText(markdown: string, text: string): boolean
	return markdown:find(text, 1, true) ~= nil
end

test.suite("renderSizeReport", function(suite)
	suite:case("starts with the marker that identifies the comment", function(assert)
		assert.eq(renderSizeReport(getReport()):sub(1, 21), "<!-- size-report -->\n")
	end)

	suite:case("leaves the comparison columns empty when there's no base report", function(assert)
		local markdown = renderSizeReport(getReport())

		assert.eq(hasLine(markdown, "|  | Bundle | `main` | This commit | Change |"), true)
		assert.eq(hasLine(markdown, "|  | Plugin (prod) |  | 2.50 MB |  |"), true)
		assert.eq(hasText(markdown, "There's no report from `main` yet"), true)
	end)

	suite:case("shows each bundle beside its size on main", function(assert)
		local baseReport = getBaseReport()
		baseReport.bundles = {
			{ name = "Plugin (prod)", bytes = 4_000_000 },
			{ name = "Storybook place", bytes = 4_000_000 },
		}
		local report = getReport()
		table.insert(report.bundles, {
			name = "Plugin (dev)",
			bytes = 4_100_000,
		})

		local markdown = renderSizeReport(report, baseReport)

		assert.eq(hasLine(markdown, "| 🟢 | Plugin (prod) | 4.00 MB | 2.50 MB | **−1.50 MB** (−37.5%) |"), true)
		assert.eq(hasLine(markdown, "| ⚪ | Storybook place | 4.00 MB | 4.00 MB | no change |"), true)
		assert.eq(hasLine(markdown, "| 🆕 | Plugin (dev) |  | 4.10 MB | new |"), true)
	end)

	suite:case("sums up what changed and calls out the largest change", function(assert)
		local baseReport = getBaseReport()
		baseReport.bundles = {
			{ name = "Plugin (prod)", bytes = 4_000_000 },
			{ name = "Storybook place", bytes = 4_000_000 },
		}

		local markdown = renderSizeReport(getReport(), baseReport)

		assert.eq(
			hasLine(markdown, "Comparing `bbbbbbb` with `main` at `aaaaaaa` across 2 bundles: 1 smaller, 1 unchanged."),
			true
		)
		assert.eq(hasLine(markdown, "> [!TIP]"), true)
		assert.eq(
			hasLine(
				markdown,
				"> 📉 **1 bundle got smaller.** The largest change is Plugin (prod), down 1.50 MB (−37.5%)."
			),
			true
		)
	end)

	suite:case("warns about the bundle that grew, even when another shrank by more", function(assert)
		local baseReport = getBaseReport()
		baseReport.bundles = {
			{ name = "Plugin (prod)", bytes = 2_000_000 },
			{ name = "Storybook place", bytes = 5_000_000 },
		}

		local markdown = renderSizeReport(getReport(), baseReport)

		assert.eq(hasLine(markdown, "> [!WARNING]"), true)
		assert.eq(
			hasLine(
				markdown,
				"> 📈 **1 bundle got bigger.** The largest change is Plugin (prod), up 500.0 kB (+25.0%)."
			),
			true
		)
	end)

	suite:case("counts a change of a few bytes as unchanged", function(assert)
		local baseReport = getBaseReport()
		baseReport.bundles = {
			{ name = "Plugin (prod)", bytes = 2_500_040 },
			{ name = "Storybook place", bytes = 4_000_000 },
		}

		local markdown = renderSizeReport(getReport(), baseReport)

		assert.eq(hasLine(markdown, "| ⚪ | Plugin (prod) | 2.50 MB | 2.50 MB | −40 B |"), true)
		assert.eq(hasText(markdown, "[!"), false)
	end)

	suite:case("fills the storybook deploy's bar by how close it is to the limit", function(assert)
		local markdown = renderSizeReport(getReport())

		assert.eq(hasLine(markdown, `{("🟨"):rep(16)}{("⬜"):rep(4)} **78%** · 6.50 MB of 8.36 MB`), true)
	end)

	suite:case("says when the chart will show up while there's only one commit", function(assert)
		local markdown = renderSizeReport(getReport())

		assert.eq(hasText(markdown, "xychart-beta"), false)
		assert.eq(hasText(markdown, "shows up here once `main` has a report to start from"), true)
	end)

	suite:case("charts the prod plugin's size at each commit", function(assert)
		local report = getReport()
		report.history = {
			{ sha = "1111111", bytes = { ["Plugin (prod)"] = 4_280_000 } },
			{ sha = "aaaaaaa", bytes = { ["Plugin (prod)"] = 4_300_000 } },
			{ sha = "bbbbbbb", bytes = { ["Plugin (prod)"] = 2_500_000 } },
		}

		local markdown = renderSizeReport(report)

		assert.eq(hasLine(markdown, '    x-axis ["1111111", "aaaaaaa", "bbbbbbb"]'), true)
		assert.eq(hasLine(markdown, '    y-axis "Size (MB)" 0 --> 5'), true)
		assert.eq(hasLine(markdown, "    line [4.28, 4.30, 2.50]"), true)
	end)

	suite:case("charts only the latest commits", function(assert)
		local report = getReport()
		local history: { renderSizeReport.HistoryEntry } = {}
		report.history = history
		for index = 1, 15 do
			local entry: renderSizeReport.HistoryEntry = {
				sha = `commit{index}`,
				bytes = { ["Plugin (prod)"] = 2_500_000 },
			}
			table.insert(history, entry)
		end

		local markdown = renderSizeReport(report)

		assert.eq(hasText(markdown, '"commit3"'), false)
		assert.eq(hasText(markdown, 'x-axis ["commit4", '), true)
	end)

	suite:case("draws the prod plugin's parts as a pie and folds the small ones together", function(assert)
		local markdown = renderSizeReport(getReport())

		assert.eq(hasLine(markdown, '    "Packages (MB)" : 0.80'), true)
		assert.eq(hasLine(markdown, '    "Everything else (MB)" : 0.01'), true)
		assert.eq(hasText(markdown, '"src (MB)"'), false)
	end)

	suite:case("lists every part with a dash where a channel leaves it out", function(assert)
		local markdown = renderSizeReport(getReport())

		assert.eq(hasLine(markdown, "| `Packages` | 800.0 kB | 2.00 MB |"), true)
		assert.eq(hasLine(markdown, "| `workspace/example` | – | 7.0 kB |"), true)
		assert.eq(hasLine(markdown, "| `src` | 900 B | 900 B |"), true)
	end)

	suite:case("notes only the parts that changed from main", function(assert)
		local baseReport = getBaseReport()
		baseReport.parts = {
			{ name = "Packages", bytes = { prod = 790_000, dev = 2_000_000 } },
			{ name = "src", bytes = { prod = 900, dev = 900 } },
		}

		local markdown = renderSizeReport(getReport(), baseReport)

		assert.eq(hasLine(markdown, "| `Packages` | 800.0 kB 🟠 +10.0 kB | 2.00 MB |"), true)
		assert.eq(hasLine(markdown, "| `workspace/example` | – | 7.0 kB 🆕 |"), true)
		assert.eq(hasLine(markdown, "| `src` | 900 B | 900 B |"), true)
	end)

	suite:case("links the footer to the run that measured the report", function(assert)
		local markdown = renderSizeReport(getReport(), nil, {
			runUrl = "https://example.com/run",
		})

		assert.eq(hasText(markdown, "<sub>Measured bbbbbbb in [this run](https://example.com/run)."), true)
	end)
end)
