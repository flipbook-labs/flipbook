local test = require("@std/test")

local renderSizeReport = require("./renderSizeReport")

type Report = renderSizeReport.Report

local function getReport(): Report
	return {
		bundles = {
			{ name = "Plugin (prod)", bytes = 2_500_000 },
			{ name = "Storybook place", bytes = 4_000_000 },
		},
		channels = { "prod", "dev" },
		parts = {
			{ name = "Packages", bytes = { prod = 800_000, dev = 2_000_000 } },
			{ name = "workspace/example", bytes = { dev = 7_000 } },
			{ name = "src", bytes = { prod = 900, dev = 900 } },
		},
		storybookDeployBytes = 6_500_000,
	}
end

local function hasLine(markdown: string, line: string): boolean
	return (`\n{markdown}`):find(`\n{line}\n`, 1, true) ~= nil
end

test.suite("renderSizeReport", function(suite)
	suite:case("starts with the marker that identifies the comment", function(assert)
		assert.eq(renderSizeReport(getReport()):sub(1, 21), "<!-- size-report -->\n")
	end)

	suite:case("shows each size in the largest unit that fits", function(assert)
		local markdown = renderSizeReport(getReport())

		assert.eq(hasLine(markdown, "| Plugin (prod) | 2.50 MB |"), true)
		assert.eq(hasLine(markdown, "| `Packages` | 800.0 kB | 2.00 MB |"), true)
		assert.eq(hasLine(markdown, "| `src` | 900 B | 900 B |"), true)
	end)

	suite:case("leaves the cell empty for a channel that doesn't have the part", function(assert)
		assert.eq(hasLine(renderSizeReport(getReport()), "| `workspace/example` | – | 7.0 kB |"), true)
	end)

	suite:case("says there's nothing to compare with when there's no base report", function(assert)
		local markdown = renderSizeReport(getReport())

		assert.eq(hasLine(markdown, "| Bundle | Size |"), true)
		assert.eq(hasLine(markdown, "There's no report from `main` to compare with yet."), true)
	end)

	suite:case("shows how each bundle changed from the base report", function(assert)
		local baseReport = getReport()
		baseReport.bundles = {
			{ name = "Plugin (prod)", bytes = 4_000_000 },
			{ name = "Storybook place", bytes = 4_000_000 },
		}
		local report = getReport()
		table.insert(report.bundles, { name = "Plugin (dev)", bytes = 4_100_000 })

		local markdown = renderSizeReport(report, baseReport)

		assert.eq(hasLine(markdown, "| Plugin (prod) | 2.50 MB | −1.50 MB (−37.5%) |"), true)
		assert.eq(hasLine(markdown, "| Storybook place | 4.00 MB | no change |"), true)
		assert.eq(hasLine(markdown, "| Plugin (dev) | 4.10 MB | new |"), true)
	end)

	suite:case("notes only the parts that changed from the base report", function(assert)
		local baseReport = getReport()
		baseReport.parts = {
			{ name = "Packages", bytes = { prod = 790_000, dev = 2_000_000 } },
			{ name = "src", bytes = { prod = 900, dev = 900 } },
		}

		local markdown = renderSizeReport(getReport(), baseReport)

		assert.eq(hasLine(markdown, "| `Packages` | 800.0 kB (+10.0 kB) | 2.00 MB |"), true)
		assert.eq(hasLine(markdown, "| `workspace/example` | – | 7.0 kB (new) |"), true)
		assert.eq(hasLine(markdown, "| `src` | 900 B | 900 B |"), true)
	end)

	suite:case("shows the storybook deploy's size beside the limit", function(assert)
		assert.eq(
			renderSizeReport(getReport()):find("That's 6.50 MB of the 8.36 MB that Roblox is known to accept.", 1, true)
				~= nil,
			true
		)
	end)
end)
