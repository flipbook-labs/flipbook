local FlipbookBatteries = require("@flipbook-batteries")
local fs = require("@std/fs")
local json = require("@std/json")

local project = require("@repo/project")
local rewriteLuau = require("@scripts/lib/build-system/rewriteLuau")
local types = require("@scripts/lib/build-system/types")

local run = FlipbookBatteries.run

-- Maps the source tree with `rojo sourcemap`, so the rewriter knows which
-- instance each file becomes. The build output keeps the same layout, so the
-- instance paths it writes hold there too.
local function createRewriterAsync(context: types.BuildContext): rewriteLuau.Rewriter
	run("rojo", {
		"sourcemap",
		project.SOURCEMAP_PROJECT_PATH,
		"-o",
		project.BUILD_SOURCEMAP_PATH,
	})

	return rewriteLuau.create({
		repoPath = tostring(project.REPO_PATH),
		sourcemap = json.deserialize(fs.readFileToString(project.BUILD_SOURCEMAP_PATH)) :: any,
		globalNames = project.BUILD_GLOBALS,
		globalValues = context.env,
	})
end

return createRewriterAsync
