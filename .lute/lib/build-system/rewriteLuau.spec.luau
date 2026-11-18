local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")
local system = require("@std/system")
local test = require("@std/test")

local rewriteLuau = require("./rewriteLuau")

local repoPath = path.join(system.tmpdir(), `flipbook-rewrite-luau-{process.pid()}`)

local function writeFile(relative: string, contents: string)
	local file = path.join(repoPath, relative)
	fs.createDirectory(path.dirname(file), { makeParents = true })
	fs.writeStringToFile(file, contents)
end

-- A small repo laid out like Flipbook: plugin scripts in `src`, packages in
-- `Packages`, and a workspace member whose `.luaurc` defines `@root`.
local sourcemap: rewriteLuau.SourcemapNode = {
	name = "Root",
	children = {
		{ name = "Plugin", filePaths = { "src/Plugin.server.luau" } },
		{
			name = "Packages",
			children = {
				{ name = "React", filePaths = { "Packages/React.lua" } },
			},
		},
		{
			name = "workspace",
			children = {
				{
					name = "my-member",
					filePaths = { "workspace/my-member/src/init.luau" },
					children = {
						{ name = "Button", filePaths = { "workspace/my-member/src/Button.luau" } },
						{
							name = "Utils",
							children = {
								{ name = "format", filePaths = { "workspace/my-member/src/Utils/format.luau" } },
							},
						},
					},
				},
			},
		},
	},
}

local function createRewriter(globalValues: { [string]: string }?)
	return rewriteLuau.create({
		repoPath = path.format(repoPath),
		sourcemap = sourcemap,
		globalNames = { "BUILD_CHANNEL", "BASE_URL" },
		globalValues = globalValues or {},
	})
end

test.suite("RewriteLuau", function(suite)
	suite:beforeAll(function()
		writeFile(".config.luau", [[return { luau = { aliases = { pkg = "./Packages", workspace = "./workspace" } } }]])
		writeFile("workspace/my-member/.luaurc", [[{ "aliases": { "root": "./src", "pkg": "../../Packages" } }]])
	end)

	suite:afterAll(function()
		fs.removeDirectory(repoPath, { recursive = true })
	end)

	suite:case("resolvesSelfAndRelativeRequires", function(assert)
		local rewriter = createRewriter()
		assert.eq(
			rewriteLuau.rewriteSource(rewriter, `return require("@self/Button")`, "workspace/my-member/src/init.luau"),
			"return require(script.Button)"
		)
		assert.eq(
			rewriteLuau.rewriteSource(
				rewriter,
				`return require("./Utils/format")`,
				"workspace/my-member/src/Button.luau"
			),
			"return require(script.Parent.Utils.format)"
		)
		assert.eq(
			rewriteLuau.rewriteSource(
				rewriter,
				`return require("../Button")`,
				"workspace/my-member/src/Utils/format.luau"
			),
			"return require(script.Parent.Parent.Button)"
		)
	end)

	suite:case("resolvesAliasesFromTheNearestConfig", function(assert)
		local rewriter = createRewriter()
		assert.eq(
			rewriteLuau.rewriteSource(
				rewriter,
				`return require("@root/Button")`,
				"workspace/my-member/src/Utils/format.luau"
			),
			"return require(script.Parent.Parent.Button)"
		)
		assert.eq(
			rewriteLuau.rewriteSource(rewriter, `return require("@pkg/React")`, "workspace/my-member/src/Button.luau"),
			"return require(script.Parent.Parent.Parent.Packages.React)"
		)
	end)

	suite:case("indexesNamesThatArentIdentifiersWithBrackets", function(assert)
		local rewriter = createRewriter()
		assert.eq(
			rewriteLuau.rewriteSource(rewriter, `return require("@workspace/my-member/src")`, "src/Plugin.server.luau"),
			`return require(script.Parent.workspace["my-member"])`
		)
	end)

	suite:case("replacesListedGlobalsAndLeavesOthers", function(assert)
		local rewriter = createRewriter({ BUILD_CHANNEL = "production" })
		assert.eq(
			rewriteLuau.rewriteSource(
				rewriter,
				"print(_G.BUILD_CHANNEL, _G.BASE_URL, _G.__DEV__)",
				"src/Plugin.server.luau"
			),
			`print("production", nil, _G.__DEV__)`
		)
	end)

	suite:case("failsOnRequiresItCantResolve", function(assert)
		local rewriter = createRewriter()
		assert.throws(function()
			rewriteLuau.rewriteSource(rewriter, `return require("@missing/Thing")`, "src/Plugin.server.luau")
		end)
		assert.throws(function()
			rewriteLuau.rewriteSource(rewriter, `return require("./Nowhere")`, "src/Plugin.server.luau")
		end)
	end)
end)
