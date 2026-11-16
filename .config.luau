return {
	luau = {
		languagemode = "strict",
		aliases = {
			lune = "~/.lune/.typedefs/0.9.4/",
			lint = "~/.lute/typedefs/1.0.1/lint",
			lute = "~/.lute/typedefs/1.0.1/lute",
			std = "~/.lute/typedefs/1.0.1/std",
			lunepkg = "./LuauPackages",
			pkg = "./Packages",
			rbxpkg = "./RobloxPackages",
			repo = ".",
			scripts = "./.lute",
			workspace = "./workspace",

			-- `lute run install` writes these paths from `pkg.lock.luau`.
			batteries = "~/.loom/store/lute--github-6e87d56ef86974ca90629c5ef7ab70e40b102f8210ee178dc95916f940d6854e@6dba55fa3cf083d10fb5dcb54a22cb87d3d11735a512215b835f33d3c571033d/batteries",
			flipbookbatteries = "~/.loom/store/flipbook-batteries--github-cd561061b96224c3881d0f76944a9bb8bad2d09ff72e9e09eb3cfaa2e62b6613@2f0b52aa834b5bccd5b10d223b712227121916715a67505b557393845d5af93e",
		},
	},
}
