return {
	luau = {
		languagemode = "strict",
		aliases = {
			lint = "~/.lute/typedefs/1.0.1/lint",
			lpm = "./.lpm",
			lute = "~/.lute/typedefs/1.0.1/lute",
			std = "~/.lute/typedefs/1.0.1/std",
			pkg = "./Packages",
			rbxpkg = "./RobloxPackages",
			repo = ".",
			scripts = "./.lute",
			workspace = "./workspace",
		},
	},
	lute = {
		lint = {
			ruleconfigs = {
				-- Flipbook reads build globals like `_G.BUILD_CHANNEL` and sets
				-- `_G.__DEV__` on purpose, and `selene.toml` allows `_G` too.
				global_usage = { off = true },
			},
		},
	},
}
