-- The root has no name or version, which makes it a virtual package: it
-- isn't a package itself, and its path dependencies are the workspace
-- members. Members in `dependencies` ship with the plugin. Members in
-- `dev_dependencies` only exist for development, so production builds prune
-- them. The other dependencies are tooling for the `.lute` scripts.
local function member(name: string)
	return { sourceKind = "path", source = `./workspace/{name}` }
end

return {
	package = {
		dependencies = {
			["flipbook-agents"] = member("flipbook-agents"),
			["flipbook-core"] = member("flipbook-core"),
			["flipbook-next"] = member("flipbook-next"),

			batteries = {
				rev = "v1.0.1-nightly.20261115",
				sourceKind = "github",
				source = "https://github.com/luau-lang/lute",
				target = "batteries",
			},
			["flipbook-batteries"] = {
				rev = "v0.13.1",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/flipbook-batteries",
			},
		},
		dev_dependencies = {
			["code-samples"] = member("code-samples"),
			example = member("example"),
			template = member("template"),
			["test-runner"] = member("test-runner"),

			["agent-skills"] = {
				rev = "v0.7.0",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/agent-skills",
			},
		},
	},
}
